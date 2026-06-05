import SwiftUI
import SwiftData

struct ReaderTarget: Identifiable { let story: Story; let index: Int; var id: String { "\(story.id)-\(index)" } }

struct StoryDetailView: View {
    let story: Story
    @Environment(\.modelContext) private var ctx
    @EnvironmentObject private var content: ContentStore
    @EnvironmentObject private var entitlement: EntitlementStore
    @Query private var saved: [SavedStory]
    @Query private var progresses: [ReadingProgress]
    @State private var reader: ReaderTarget?
    @State private var showPaywall = false

    private var isSaved: Bool { saved.contains { $0.storyId == story.id } }
    private var progress: ReadingProgress? { progresses.first { $0.storyId == story.id } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 16) {
                    StoryCover(story: story, width: 120)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(story.title).font(.system(size: 24, weight: .bold, design: .serif)).foregroundStyle(Theme.textPrimary)
                        Text("by \(story.author)").font(.subheadline).foregroundStyle(Theme.textSecondary)
                        if content.isFreeFull(story) {
                            Text("FREE THIS WEEK").font(.caption2.weight(.bold)).tracking(1)
                                .foregroundStyle(Theme.accent)
                        }
                        FlowTags(tags: [story.genre, story.trope] + story.tags.prefix(2))
                    }
                    Spacer()
                }
                Button { startReading() } label: {
                    Label(progress != nil ? "Continue · Ch \((progress?.chapterIndex ?? 0) + 1)" : "Start reading",
                          systemImage: "book.fill")
                        .font(.headline).frame(maxWidth: .infinity).padding(.vertical, 6)
                }.buttonStyle(.borderedProminent).controlSize(.large).tint(Theme.accent)
                    .accessibilityIdentifier("startReading")

                Text(story.blurb).font(.body).foregroundStyle(Theme.textPrimary).fixedSize(horizontal: false, vertical: true)

                Text("Chapters").font(.title3.bold()).foregroundStyle(Theme.textPrimary).padding(.top, 4)
                VStack(spacing: 0) {
                    ForEach(story.chapters) { ch in
                        let locked = content.isLocked(story, chapterIndex: ch.index, isPro: entitlement.isPro)
                        Button { open(ch.index, locked: locked) } label: { chapterRow(ch, locked: locked) }
                            .buttonStyle(.plain)
                        if ch.index != story.chapters.count - 1 { Divider().overlay(Theme.hairline) }
                    }
                }.card(8)

                recRow("More \(story.genre)", content.stories.filter { $0.id != story.id && $0.genre == story.genre })
                recRow("You may also like", content.stories.filter { $0.id != story.id && $0.genre != story.genre })
            }.padding(16)
        }
        .background(Theme.canvas.ignoresSafeArea())
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { toggleSave() } label: { Image(systemName: isSaved ? "bookmark.fill" : "bookmark") }
                    .tint(Theme.accent)
            }
        }
        .fullScreenCover(item: $reader) { t in ReaderView(story: t.story, initialIndex: t.index) }
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }

    private func chapterRow(_ ch: Chapter, locked: Bool) -> some View {
        HStack(spacing: 12) {
            Text("\(ch.index + 1)").font(.subheadline.monospacedDigit()).foregroundStyle(Theme.textSecondary).frame(width: 24)
            Text(ch.title).font(.subheadline).foregroundStyle(Theme.textPrimary).lineLimit(1)
            Spacer()
            Image(systemName: locked ? "lock.fill" : "chevron.right")
                .font(.footnote).foregroundStyle(locked ? Theme.accent : Theme.textSecondary)
        }.padding(.vertical, 12).padding(.horizontal, 8).contentShape(Rectangle())
    }

    @ViewBuilder private func recRow(_ title: String, _ stories: [Story]) -> some View {
        if !stories.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text(title).font(.headline).foregroundStyle(Theme.textPrimary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 12) {
                        ForEach(stories.prefix(8)) { s in
                            NavigationLink(value: s) { StoryCover(story: s, width: 104) }.buttonStyle(.plain)
                        }
                    }
                }
            }.padding(.top, 4)
        }
    }

    private func startReading() { open(progress?.chapterIndex ?? 0, locked: false) }
    private func open(_ index: Int, locked: Bool) {
        if locked { showPaywall = true } else { reader = ReaderTarget(story: story, index: index) }
    }
    private func toggleSave() {
        if let s = saved.first(where: { $0.storyId == story.id }) { ctx.delete(s) }
        else { ctx.insert(SavedStory(storyId: story.id)) }
    }
}

struct FlowTags: View {
    let tags: [String]
    var body: some View {
        HStack(spacing: 6) { ForEach(Array(tags.prefix(3)), id: \.self) { TagChip(text: $0) } }
    }
}
