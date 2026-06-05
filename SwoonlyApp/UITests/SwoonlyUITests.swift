import XCTest

final class SwoonlyUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    func testLaunchAndBrowse() {
        let app = XCUIApplication()
        app.launchArguments = ["--screenshots"]
        app.launch()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 8))
    }

    func testScreenshots() {
        let app = XCUIApplication()
        app.launchArguments = ["--screenshots"]
        app.launch()
        snapshotAttach(app, "01_library")
        if app.buttons["Browse"].exists { app.buttons["Browse"].tap() }
        snapshotAttach(app, "02_browse")
    }

    private func snapshotAttach(_ app: XCUIApplication, _ name: String) {
        let s = app.screenshot()
        let a = XCTAttachment(screenshot: s); a.name = name; a.lifetime = .keepAlways; add(a)
    }
}
