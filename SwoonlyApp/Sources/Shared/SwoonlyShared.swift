import Foundation

/// Snapshot shared with the widget via the App Group (no SwiftData dependency).
struct SwoonlySnapshot: Codable {
    var isPro: Bool
    var currentTitle: String?
    var currentChapter: Int?
    var nextChapterTitle: String?
    var streak: Int
    var updatedAt: Date

    static let placeholder = SwoonlySnapshot(isPro: false, currentTitle: "Moonbound",
        currentChapter: 2, nextChapterTitle: "The Scent of Rain", streak: 3, updatedAt: .now)
}
