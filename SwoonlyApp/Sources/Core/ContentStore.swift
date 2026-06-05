import Foundation
import UIKit

// MARK: - Catalog content
// Bundled (Resources/Content/catalog.json) = the 3 launch books: instant, offline, review-safe.
// Remote (Cloudflare Worker) = books added post-launch: fetched, merged, and cached on disk.
// New remote books therefore appear WITHOUT an app update.

struct Chapter: Codable, Identifiable, Hashable {
    let index: Int
    let title: String
    let body: String
    var id: Int { index }
}

struct Story: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let author: String
    let genre: String
    let trope: String
    let blurb: String
    let tags: [String]
    let accent: String
    let chapters: [Chapter]
}

private struct Catalog: Codable { let stories: [Story] }

// Shape returned by GET /v1/catalog (metadata only; chapters fetched separately).
private struct RemoteMeta: Codable {
    let id, title, author, genre, trope, accent, blurb: String
    let tags: [String]
    let generatedCount: Int
}
private struct RemoteCatalog: Codable { let stories: [RemoteMeta] }
private struct RemoteChapters: Codable { let chapters: [Chapter] }

@MainActor
final class ContentStore: ObservableObject {
    static let shared = ContentStore()
    @Published private(set) var stories: [Story] = []

    /// First N chapters of every story are free; the rest need Pro — unless the story is in the free rotation.
    let freeChapterLimit = 3

    private let apiBase = "https://swoonly-content.hxu92521.workers.dev"
    private var bundledStories: [Story] = []
    private var bundledIDs: Set<String> = []

    private let cachesDir: URL = {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("SwoonlyContent", isDirectory: true)
    }()
    private var remoteCacheURL: URL { cachesDir.appendingPathComponent("remote_catalog.json") }
    private func remoteCoverURL(_ id: String) -> URL { cachesDir.appendingPathComponent("cover_\(id).img") }

    init() {
        try? FileManager.default.createDirectory(at: cachesDir, withIntermediateDirectories: true)
        loadBundled()
        loadRemoteCache()        // instant + offline: show last-known remote books immediately
        publish()
        Task { await refreshRemote() }   // then update from the network in the background
    }

    // MARK: bundled

    private func loadBundled() {
        guard let url = Bundle.main.url(forResource: "catalog", withExtension: "json", subdirectory: "Content")
                ?? Bundle.main.url(forResource: "catalog", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let cat = try? JSONDecoder().decode(Catalog.self, from: data) else { return }
        bundledStories = cat.stories.filter { !$0.chapters.isEmpty }
        bundledIDs = Set(bundledStories.map { $0.id })
    }

    // MARK: remote

    private var remoteStories: [Story] = []

    private func loadRemoteCache() {
        guard let data = try? Data(contentsOf: remoteCacheURL),
              let cached = try? JSONDecoder().decode([Story].self, from: data) else { return }
        remoteStories = cached.filter { !bundledIDs.contains($0.id) && !$0.chapters.isEmpty }
    }

    private func saveRemoteCache() {
        if let data = try? JSONEncoder().encode(remoteStories) { try? data.write(to: remoteCacheURL) }
    }

    private func publish() {
        stories = bundledStories + remoteStories.sorted { $0.title < $1.title }
    }

    /// Pull the remote catalog, fetch chapters+cover for any non-bundled book, merge, cache.
    func refreshRemote() async {
        guard let url = URL(string: "\(apiBase)/v1/catalog"),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let cat = try? JSONDecoder().decode(RemoteCatalog.self, from: data) else { return }

        var built: [Story] = []
        for meta in cat.stories where !bundledIDs.contains(meta.id) {
            // reuse cached chapters if the book hasn't grown since last fetch
            if let cached = remoteStories.first(where: { $0.id == meta.id }), cached.chapters.count >= meta.generatedCount {
                built.append(cached)
            } else if let chapters = await fetchChapters(meta.id, count: meta.generatedCount), !chapters.isEmpty {
                built.append(Story(id: meta.id, title: meta.title, author: meta.author, genre: meta.genre,
                                   trope: meta.trope, blurb: meta.blurb, tags: meta.tags, accent: meta.accent,
                                   chapters: chapters))
            }
            await fetchCoverIfNeeded(meta.id)
        }
        remoteStories = built
        saveRemoteCache()
        publish()
    }

    private func fetchChapters(_ id: String, count: Int) async -> [Chapter]? {
        let to = max(0, count - 1)
        guard let url = URL(string: "\(apiBase)/v1/books/\(id)/chapters?from=0&to=\(to)"),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let res = try? JSONDecoder().decode(RemoteChapters.self, from: data) else { return nil }
        return res.chapters.sorted { $0.index < $1.index }
    }

    private func fetchCoverIfNeeded(_ id: String) async {
        let dst = remoteCoverURL(id)
        if FileManager.default.fileExists(atPath: dst.path) { return }
        guard let url = URL(string: "\(apiBase)/v1/books/\(id)/cover"),
              let (data, resp) = try? await URLSession.shared.data(from: url),
              (resp as? HTTPURLResponse)?.statusCode == 200, !data.isEmpty else { return }
        try? data.write(to: dst)
        coverCache[id] = UIImage(data: data)
    }

    /// Tell the backend a reader reached `index` — triggers demand-based generation at the paywall.
    func signalRead(_ storyId: String, index: Int) {
        guard !bundledIDs.contains(storyId) else { return } // bundled books are complete; no need to signal
        guard let url = URL(string: "\(apiBase)/v1/signal") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "content-type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: ["bookId": storyId, "readIndex": index])
        Task { _ = try? await URLSession.shared.data(for: req) }
    }

    // MARK: covers

    private var coverCache: [String: UIImage] = [:]
    /// Cover image: bundled jpg/png, else cached remote cover; nil → gradient fallback (app overlays the title).
    func cover(_ id: String) -> UIImage? {
        if let c = coverCache[id] { return c }
        for ext in ["jpg", "png"] {
            if let u = Bundle.main.url(forResource: id, withExtension: ext, subdirectory: "Content/covers")
                ?? Bundle.main.url(forResource: id, withExtension: ext),
               let img = UIImage(contentsOfFile: u.path) { coverCache[id] = img; return img }
        }
        let remote = remoteCoverURL(id)
        if FileManager.default.fileExists(atPath: remote.path), let img = UIImage(contentsOfFile: remote.path) {
            coverCache[id] = img; return img
        }
        return nil
    }

    // MARK: queries (unchanged API)

    var genres: [String] { Array(NSOrderedSet(array: stories.map { $0.genre }).array as? [String] ?? []) }
    func stories(in genre: String) -> [Story] { stories.filter { $0.genre == genre } }
    func story(_ id: String) -> Story? { stories.first { $0.id == id } }

    /// One rotating fully-free story (changes weekly) so there is always a no-paywall full read.
    var freeFullStoryId: String? {
        guard !stories.isEmpty else { return nil }
        let week = Calendar.current.component(.weekOfYear, from: .now)
        return stories[week % stories.count].id
    }
    func isFreeFull(_ story: Story) -> Bool { story.id == freeFullStoryId }

    func isLocked(_ story: Story, chapterIndex: Int, isPro: Bool) -> Bool {
        if isPro || isFreeFull(story) { return false }
        return chapterIndex >= freeChapterLimit
    }
}
