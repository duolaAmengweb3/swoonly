import SwiftUI
import SwiftData

struct LibraryView: View {
    @EnvironmentObject private var content: ContentStore
    @Query(sort: \ReadingProgress.updatedAt, order: .reverse) private var progress: [ReadingProgress]
    @Query(sort: \SavedStory.savedAt, order: .reverse) private var saved: [SavedStory]

    private var continueStories: [(Story, ReadingProgress)] {
        progress.compactMap { p in content.story(p.storyId).map { ($0, p) } }
    }
    private var savedStories: [Story] { saved.compactMap { content.story($0.storyId) } }

    var body: some View {
        NavigationStack {
            ScrollView {
                if continueStories.isEmpty && savedStories.isEmpty {
                    EmptyStateView(symbol: "book.closed", title: "Your library is empty",
                                   message: "Find a story you love — the first chapters are always free.")
                        .padding(.top, 60)
                } else {
                    VStack(alignment: .leading, spacing: 28) {
                        if !continueStories.isEmpty {
                            Section_("Continue reading") {
                                VStack(spacing: 12) {
                                    ForEach(continueStories, id: \.0.id) { story, p in
                                        NavigationLink(value: story) { ContinueRow(story: story, progress: p) }
                                            .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        if !savedStories.isEmpty {
                            Section_("Saved") {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(alignment: .top, spacing: 14) {
                                        ForEach(savedStories) { s in
                                            NavigationLink(value: s) { StoryCover(story: s) }.buttonStyle(.plain)
                                        }
                                    }.padding(.horizontal, 16)
                                }.padding(.horizontal, -16)
                            }
                        }
                    }.padding(16)
                }
            }
            .background(Theme.canvas.ignoresSafeArea())
            .navigationTitle("Library")
            .navigationDestination(for: Story.self) { StoryDetailView(story: $0) }
        }
    }
}

private struct Section_<C: View>: View {
    let title: String; @ViewBuilder var content: C
    init(_ t: String, @ViewBuilder content: () -> C) { title = t; self.content = content() }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.title3.bold()).foregroundStyle(Theme.textPrimary)
            content
        }
    }
}

struct ContinueRow: View {
    let story: Story; let progress: ReadingProgress
    var body: some View {
        let total = max(story.chapters.count, 1)
        HStack(spacing: 14) {
            StoryCover(story: story, width: 70)
            VStack(alignment: .leading, spacing: 6) {
                Text(story.title).font(.headline).foregroundStyle(Theme.textPrimary).lineLimit(2)
                Text("Chapter \(progress.chapterIndex + 1) of \(total)").font(.caption).foregroundStyle(Theme.textSecondary)
                ProgressView(value: Double(progress.chapterIndex), total: Double(total)).tint(Theme.accent)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.footnote).foregroundStyle(Theme.textSecondary)
        }.card()
    }
}
