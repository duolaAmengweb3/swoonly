import SwiftUI

struct BrowseView: View {
    @EnvironmentObject private var content: ContentStore
    @State private var query = ""

    private var results: [Story] {
        guard !query.isEmpty else { return [] }
        let q = query.lowercased()
        return content.stories.filter {
            $0.title.lowercased().contains(q) || $0.genre.lowercased().contains(q)
            || $0.trope.lowercased().contains(q) || $0.tags.contains { $0.lowercased().contains(q) }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if !query.isEmpty {
                    grid(results.isEmpty ? content.stories : results)
                } else {
                    VStack(alignment: .leading, spacing: 28) {
                        if let id = content.freeFullStoryId, let s = content.story(id) { freeBanner(s) }
                        ForEach(content.genres, id: \.self) { genre in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(genre).font(.title3.bold()).foregroundStyle(Theme.textPrimary).padding(.horizontal, 16)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(alignment: .top, spacing: 14) {
                                        ForEach(content.stories(in: genre)) { s in
                                            NavigationLink(value: s) { StoryCover(story: s) }.buttonStyle(.plain)
                                        }
                                    }.padding(.horizontal, 16)
                                }
                            }
                        }
                    }.padding(.vertical, 8)
                }
            }
            .background(Theme.canvas.ignoresSafeArea())
            .navigationTitle("Browse")
            .searchable(text: $query, prompt: "Search stories, genres, tropes")
            .navigationDestination(for: Story.self) { StoryDetailView(story: $0) }
        }
    }

    private func freeBanner(_ s: Story) -> some View {
        NavigationLink(value: s) {
            HStack(spacing: 14) {
                StoryCover(story: s, width: 64)
                VStack(alignment: .leading, spacing: 4) {
                    Text("FREE THIS WEEK").font(.caption2.weight(.bold)).tracking(1).foregroundStyle(Theme.accent)
                    Text(s.title).font(.headline).foregroundStyle(Theme.textPrimary).lineLimit(2)
                    Text("Read the whole book — no paywall.").font(.caption).foregroundStyle(Theme.textSecondary)
                }
                Spacer(); Image(systemName: "chevron.right").foregroundStyle(Theme.textSecondary)
            }.card().padding(.horizontal, 16)
        }.buttonStyle(.plain)
    }

    private func grid(_ stories: [Story]) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: 14)], alignment: .leading, spacing: 18) {
            ForEach(stories) { s in NavigationLink(value: s) { StoryCover(story: s) }.buttonStyle(.plain) }
        }.padding(16)
    }
}
