import XCTest

final class LockedPhotosUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testDemoDontSwipeViewerStaysWithinSelectedPhotosAndZooms() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["useDemoSetButton"].tap()

        let selectedCount = app.staticTexts["selectedCountLabel"]
        XCTAssertTrue(selectedCount.waitForExistence(timeout: 3))
        XCTAssertEqual(selectedCount.label, "3 selected")

        app.buttons["startHandoffButton"].tap()

        let counter = app.buttons["handoffCounter"]
        XCTAssertTrue(counter.waitForExistence(timeout: 3))
        XCTAssertEqual(counter.label, "Photo 1 of 3")
        XCTAssertTrue(app.buttons["endHandoffButton"].waitForExistence(timeout: 3))
        XCTAssertEqual(app.buttons["endHandoffButton"].label, "Unlock to exit Don't Swipe")
        XCTAssertTrue(app.staticTexts["photoInfoDateLabel"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts["photoInfoDateLabel"].label.contains(" at "))
        XCTAssertTrue(app.staticTexts["photoInfoTimeLabel"].waitForExistence(timeout: 3))

        let zoomView = app.scrollViews["handoffZoomView"].firstMatch
        XCTAssertTrue(zoomView.waitForExistence(timeout: 3))

        XCTAssertTrue(app.scrollViews["handoffThumbnailStrip"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["handoffThumbnail_1"].exists)
        XCTAssertTrue(app.buttons["handoffThumbnail_2"].exists)
        XCTAssertTrue(app.buttons["handoffThumbnail_3"].exists)

        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        waitForNonexistence(of: app.staticTexts["photoInfoDateLabel"])
        XCTAssertFalse(app.staticTexts["photoInfoTimeLabel"].exists)
        XCTAssertFalse(counter.exists)
        XCTAssertFalse(app.buttons["endHandoffButton"].exists)
        XCTAssertFalse(app.scrollViews["handoffThumbnailStrip"].exists)

        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        XCTAssertTrue(counter.waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["endHandoffButton"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["photoInfoDateLabel"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["photoInfoTimeLabel"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.scrollViews["handoffThumbnailStrip"].waitForExistence(timeout: 3))

        app.swipeLeft()
        XCTAssertEqual(counter.label, "Photo 2 of 3")

        app.swipeLeft()
        XCTAssertEqual(counter.label, "Photo 3 of 3")

        app.swipeLeft()
        XCTAssertEqual(counter.label, "Photo 3 of 3")

        zoomView.pinch(withScale: 2.0, velocity: 1.0)

        app.buttons["endHandoffButton"].tap()
        XCTAssertTrue(counter.waitForExistence(timeout: 1))
    }

    private func waitForNonexistence(of element: XCUIElement, timeout: TimeInterval = 2) {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: timeout), .completed)
    }
}
