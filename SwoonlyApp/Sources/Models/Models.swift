import Foundation
import SwiftData

// MARK: - User state (SwiftData). Story content itself is read-only, loaded from bundled catalog.json.

@Model final class AppSettings {
    var onboarded: Bool
    var readerFontSize: Double
    var readerThemeRaw: String
    var serifReading: Bool
    var lineSpacingFactor: Double
    var dailyReminder: Bool
    init(onboarded: Bool = false, readerFontSize: Double = 19, readerThemeRaw: String = "paper",
         serifReading: Bool = true, lineSpacingFactor: Double = 0.5, dailyReminder: Bool = false) {
        self.onboarded = onboarded; self.readerFontSize = readerFontSize
        self.readerThemeRaw = readerThemeRaw; self.serifReading = serifReading
        self.lineSpacingFactor = lineSpacingFactor; self.dailyReminder = dailyReminder
    }
    var readerTheme: ReaderTheme { ReaderTheme(rawValue: readerThemeRaw) ?? .paper }
}

@Model final class ReadingProgress {
    @Attribute(.unique) var storyId: String
    var chapterIndex: Int
    var scrollFraction: Double
    var updatedAt: Date
    init(storyId: String, chapterIndex: Int = 0, scrollFraction: Double = 0, updatedAt: Date = .now) {
        self.storyId = storyId; self.chapterIndex = chapterIndex
        self.scrollFraction = scrollFraction; self.updatedAt = updatedAt
    }
}

@Model final class SavedStory {
    @Attribute(.unique) var storyId: String
    var savedAt: Date
    init(storyId: String, savedAt: Date = .now) { self.storyId = storyId; self.savedAt = savedAt }
}
