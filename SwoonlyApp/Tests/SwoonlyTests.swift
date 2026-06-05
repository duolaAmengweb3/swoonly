import XCTest
@testable import Swoonly

@MainActor
final class SwoonlyTests: XCTestCase {
    private func makeStory(chapters: Int) -> Story {
        Story(id: "t", title: "T", author: "A", genre: "Werewolf", trope: "Fated", blurb: "b",
              tags: ["x"], accent: "#6E63B8",
              chapters: (0..<chapters).map { Chapter(index: $0, title: "Ch\($0)", body: "body") })
    }

    func testFreeChaptersUnlocked() {
        let cs = ContentStore.shared
        let s = makeStory(chapters: 8)
        XCTAssertFalse(cs.isLocked(s, chapterIndex: 0, isPro: false))
        XCTAssertFalse(cs.isLocked(s, chapterIndex: 2, isPro: false))
    }

    func testLockedChaptersNeedPro() {
        let cs = ContentStore.shared
        let s = makeStory(chapters: 8)
        // story is not the free-full one (catalog empty in tests → freeFullStoryId nil)
        XCTAssertTrue(cs.isLocked(s, chapterIndex: 3, isPro: false))
        XCTAssertFalse(cs.isLocked(s, chapterIndex: 3, isPro: true))
        XCTAssertFalse(cs.isLocked(s, chapterIndex: 7, isPro: true))
    }

    func testReaderThemeRoundTrip() {
        XCTAssertEqual(ReaderTheme(rawValue: "night"), .night)
        XCTAssertEqual(ReaderTheme.sepia.label, "Sepia")
    }
}
