import XCTest

final class LockedPhotosUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testDemoHandoffViewerStaysWithinSelectedPhotosAndZooms() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["useDemoSetButton"].tap()

        let selectedCount = app.staticTexts["selectedCountLabel"]
        XCTAssertTrue(selectedCount.waitForExistence(timeout: 3))
        XCTAssertEqual(selectedCount.label, "3 selected")

        app.buttons["startHandoffButton"].tap()

        let counter = app.staticTexts["handoffCounter"]
        XCTAssertTrue(counter.waitForExistence(timeout: 3))
        XCTAssertEqual(counter.label, "Photo 1 of 3")

        let zoomView = app.scrollViews["handoffZoomView"].firstMatch
        XCTAssertTrue(zoomView.waitForExistence(timeout: 3))

        XCTAssertTrue(app.scrollViews["handoffThumbnailStrip"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["handoffThumbnail_1"].exists)
        XCTAssertTrue(app.buttons["handoffThumbnail_2"].exists)
        XCTAssertTrue(app.buttons["handoffThumbnail_3"].exists)

        app.swipeLeft()
        XCTAssertEqual(counter.label, "Photo 2 of 3")

        app.swipeLeft()
        XCTAssertEqual(counter.label, "Photo 3 of 3")

        app.swipeLeft()
        XCTAssertEqual(counter.label, "Photo 3 of 3")

        zoomView.pinch(withScale: 2.0, velocity: 1.0)
    }
}
