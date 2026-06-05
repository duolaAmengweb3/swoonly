import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var ctx
    @Query private var settingsList: [AppSettings]
    @EnvironmentObject private var content: ContentStore
    @EnvironmentObject private var entitlement: EntitlementStore

    private var settings: AppSettings? { settingsList.first }

    private var skipOnboard: Bool {
        let a = ProcessInfo.processInfo.arguments
        return a.contains("--screenshots") || a.contains("--browse") || a.contains("--lockedPreview")
    }
    private var shotArg: String? { ProcessInfo.processInfo.arguments.first { $0.hasPrefix("--shot") } }

    var body: some View {
        Group {
            if let shot = shotArg, !content.stories.isEmpty {
                shotView(shot)
            } else if (settings?.onboarded ?? false) || skipOnboard {
                MainTabs()
            } else {
                OnboardingView(onDone: completeOnboarding)
            }
        }
        .task { ensureSettings() }
        .task(id: entitlement.isPro) { pushSnapshot() }
    }

    @ViewBuilder private func shotView(_ s: String) -> some View {
        switch s {
        case "--shotPaywall": PaywallView()
        case "--shotReader":  NavigationStack { ReaderView(story: content.stories[0], initialIndex: 1) }
        case "--shotDetail":  NavigationStack { StoryDetailView(story: content.stories.count > 1 ? content.stories[1] : content.stories[0]) }
        default: MainTabs()
        }
    }

    private func ensureSettings() {
        if settingsList.isEmpty { ctx.insert(AppSettings()) }
        let args = ProcessInfo.processInfo.arguments
        if args.contains("--screenshots") || args.contains("--lockedPreview") {
            settingsList.first?.onboarded = true
            seedProgress()
        }
    }
    private func completeOnboarding() {
        if settingsList.isEmpty { ctx.insert(AppSettings(onboarded: true)) }
        else { settingsList.first?.onboarded = true }
    }
    private func seedProgress() {
        for (i, st) in content.stories.prefix(2).enumerated() {
            ctx.insert(ReadingProgress(storyId: st.id, chapterIndex: i + 1, scrollFraction: 0.3))
        }
    }
    private func pushSnapshot() {
        SharedStore.save(SwoonlySnapshot(isPro: entitlement.isPro, currentTitle: content.stories.first?.title,
            currentChapter: 1, nextChapterTitle: content.stories.first?.chapters.dropFirst().first?.title,
            streak: 0, updatedAt: .now))
    }
}

struct MainTabs: View {
    // Land on Browse (all books) by default; Library is the personal shelf.
    @State private var sel: String = ProcessInfo.processInfo.arguments.contains("--library") ? "library" : "browse"
    var body: some View {
        TabView(selection: $sel) {
            LibraryView().tag("library").tabItem { Label("Library", systemImage: "books.vertical.fill") }
            BrowseView().tag("browse").tabItem { Label("Browse", systemImage: "magnifyingglass") }
            SettingsView().tag("settings").tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}
