import SwiftUI
import SwiftData
import UIKit

struct ReaderView: View {
    let story: Story
    let initialIndex: Int
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var ctx
    @EnvironmentObject private var content: ContentStore
    @EnvironmentObject private var entitlement: EntitlementStore
    @Query private var settingsList: [AppSettings]

    @State private var index = 0
    @State private var paragraphs: [String] = []
    @State private var topID: Int? = -1
    @State private var showChrome = true
    @State private var showSettings = false
    @State private var showPaywall = false

    private var settings: AppSettings { settingsList.first ?? AppSettings() }
    private var chapter: Chapter { story.chapters[min(index, story.chapters.count - 1)] }
    private var progressFrac: Double {
        guard paragraphs.count > 1, let t = topID, t >= 0 else { return 0 }
        return Double(min(t, paragraphs.count - 1)) / Double(paragraphs.count - 1)
    }

    var body: some View {
        ZStack(alignment: .top) {
            settings.readerTheme.bg.ignoresSafeArea()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: settings.readerFontSize * settings.lineSpacingFactor + 4) {
                    Text(chapter.title)
                        .font(.system(size: settings.readerFontSize + 7, weight: .bold, design: .serif))
                        .foregroundStyle(settings.readerTheme.text).id(-1).padding(.top, 70)
                    ForEach(Array(paragraphs.enumerated()), id: \.offset) { i, p in
                        Text(attributed(p))
                            .font(settings.serifReading ? .reading(settings.readerFontSize) : .system(size: settings.readerFontSize))
                            .foregroundStyle(settings.readerTheme.text)
                            .lineSpacing(settings.readerFontSize * settings.lineSpacingFactor)
                            .frame(maxWidth: .infinity, alignment: .leading).id(i)
                    }
                    endCard.id(9999)
                }
                .padding(.horizontal, 22).padding(.bottom, 56)
            }
            .scrollPosition(id: $topID)
            .scrollIndicators(.hidden)
            .contentShape(Rectangle())
            .onTapGesture { withAnimation { showChrome.toggle() } }

            Rectangle().fill(Theme.accent)
                .frame(width: UIScreen.main.bounds.width * progressFrac, height: 2)
                .frame(maxWidth: .infinity, alignment: .leading).allowsHitTesting(false)
            if showChrome { topBar }
        }
        .statusBarHidden(!showChrome)
        .sensoryFeedback(.selection, trigger: index)
        .onAppear { index = initialIndex; loadChapter(restore: true); UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false; saveProgress() }
        .onChange(of: topID) { _, _ in saveProgress() }
        .sheet(isPresented: $showSettings) { ReaderSettingsSheet(settings: settings).presentationDetents([.medium, .large]) }
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.down") }
            Spacer()
            VStack(spacing: 1) {
                Text(story.title).font(.footnote.weight(.semibold)).lineLimit(1)
                Text("Ch \(index + 1) / \(story.chapters.count)").font(.caption2).opacity(0.7)
            }
            Spacer()
            Button { showSettings = true } label: { Image(systemName: "textformat.size") }
        }
        .foregroundStyle(settings.readerTheme.text)
        .padding(.horizontal, 18).padding(.top, 6).padding(.bottom, 10)
        .background(settings.readerTheme.bg.opacity(0.98))
        .frame(maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder private var endCard: some View {
        VStack(spacing: 12) {
            Divider().overlay(settings.readerTheme.text.opacity(0.15)).padding(.bottom, 6)
            if index < story.chapters.count - 1 {
                let locked = content.isLocked(story, chapterIndex: index + 1, isPro: entitlement.isPro)
                Button { go(index + 1) } label: {
                    VStack(spacing: 4) {
                        Label(locked ? "Unlock next chapter" : "Next chapter",
                              systemImage: locked ? "lock.fill" : "arrow.right")
                            .font(.headline)
                        Text(story.chapters[index + 1].title).font(.subheadline).opacity(0.85)
                    }.frame(maxWidth: .infinity).padding(.vertical, 12)
                }.buttonStyle(.borderedProminent).controlSize(.large).tint(Theme.accent)
                if index > 0 {
                    Button("Previous chapter") { go(index - 1) }.font(.footnote).tint(settings.readerTheme.text.opacity(0.7))
                }
            } else {
                Text("The End").font(.title2.weight(.bold)).foregroundStyle(settings.readerTheme.text)
                Text("You finished \(story.title).").font(.subheadline).foregroundStyle(settings.readerTheme.text.opacity(0.7))
                Button("Back to library") { dismiss() }.buttonStyle(.bordered).tint(Theme.accent)
            }
        }.padding(.top, 36).padding(.bottom, 24)
    }

    private func loadChapter(restore: Bool) {
        paragraphs = chapter.body.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        topID = -1
        // Demand signal: reaching the paywall chapter triggers backend generation of the rest.
        content.signalRead(story.id, index: index)
        guard restore, paragraphs.count > 1, let p = savedProgress(), p.chapterIndex == index, p.scrollFraction > 0.02 else { return }
        let target = max(0, min(Int((p.scrollFraction * Double(paragraphs.count - 1)).rounded()), paragraphs.count - 1))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { withAnimation(.none) { topID = target } }
    }

    // Render inline markdown emphasis (*italic*, **bold**) inside paragraphs; fall back to plain text.
    private func attributed(_ s: String) -> AttributedString {
        var opts = AttributedString.MarkdownParsingOptions()
        opts.interpretedSyntax = .inlineOnlyPreservingWhitespace
        return (try? AttributedString(markdown: s, options: opts)) ?? AttributedString(s)
    }

    private func go(_ target: Int) {
        guard target >= 0, target < story.chapters.count else { return }
        if content.isLocked(story, chapterIndex: target, isPro: entitlement.isPro) { showPaywall = true; return }
        index = target
        loadChapter(restore: false)
        saveProgress()
    }

    private func savedProgress() -> ReadingProgress? {
        let sid = story.id
        return try? ctx.fetch(FetchDescriptor<ReadingProgress>(predicate: #Predicate { $0.storyId == sid })).first ?? nil
    }
    private func saveProgress() {
        let sid = story.id
        if let p = savedProgress() { p.chapterIndex = index; p.scrollFraction = progressFrac; p.updatedAt = .now }
        else { ctx.insert(ReadingProgress(storyId: sid, chapterIndex: index, scrollFraction: progressFrac)) }
    }
}

struct ReaderSettingsSheet: View {
    @Bindable var settings: AppSettings
    var body: some View {
        NavigationStack {
            Form {
                Section("Text size") {
                    Slider(value: $settings.readerFontSize, in: 14...26, step: 1) { Text("Size") }
                        minimumValueLabel: { Image(systemName: "textformat.size.smaller") }
                        maximumValueLabel: { Image(systemName: "textformat.size.larger") }
                    Toggle("Serif font", isOn: $settings.serifReading)
                }
                Section("Line spacing") {
                    Slider(value: $settings.lineSpacingFactor, in: 0.25...0.9, step: 0.05) { Text("Spacing") }
                        minimumValueLabel: { Image(systemName: "lineweight") }
                        maximumValueLabel: { Image(systemName: "line.3.horizontal") }
                }
                Section("Theme") {
                    Picker("Theme", selection: Binding(get: { settings.readerTheme },
                        set: { settings.readerThemeRaw = $0.rawValue })) {
                        ForEach(ReaderTheme.allCases) { Text($0.label).tag($0) }
                    }.pickerStyle(.segmented)
                }
            }.navigationTitle("Reading").navigationBarTitleDisplayMode(.inline)
        }
    }
}
