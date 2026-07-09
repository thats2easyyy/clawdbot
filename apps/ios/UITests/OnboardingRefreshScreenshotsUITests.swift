import UIKit
import XCTest

// Temporary capture harness for onboarding before/after screenshots.
// Not part of the PR: this file stays untracked and is deleted before commit.
@MainActor
final class OnboardingRefreshScreenshotsUITests: XCTestCase {
    private var app: XCUIApplication?

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        self.app?.terminate()
        self.app = nil
        try super.tearDownWithError()
    }

    func testCaptureOnboardingScreens() {
        for appearance in ["light", "dark"] {
            self.captureFlow(appearance: appearance)
        }
    }

    private func captureFlow(appearance: String) {
        self.app?.terminate()
        let app = XCUIApplication()
        app.launchArguments += [
            "--openclaw-reset-onboarding",
            "--openclaw-appearance",
            appearance,
        ]
        addUIInterruptionMonitor(withDescription: "Local network access") { alert in
            guard alert.buttons["Allow"].exists else { return false }
            alert.buttons["Allow"].tap()
            return true
        }
        app.launch()
        self.app = app

        let continueButton = app.buttons["Continue"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 10))
        self.settle()
        self.snap(app, "01-intro-\(appearance)")
        continueButton.tap()
        app.tap()

        let manualOld = app.buttons["Set Up Manually"]
        let manualNew = app.buttons["Set up manually"]
        let hasOld = manualOld.waitForExistence(timeout: 8)
        let manual = hasOld ? manualOld : manualNew
        if !hasOld {
            XCTAssertTrue(manualNew.waitForExistence(timeout: 8))
        }
        self.settle()
        self.snap(app, "02-connect-\(appearance)")
        manual.tap()

        let homeRow = app.staticTexts["Home Network"]
        XCTAssertTrue(homeRow.waitForExistence(timeout: 8))
        self.settle()
        self.snap(app, "03-mode-\(appearance)")
        homeRow.tap()
        self.settle()
        self.snap(app, "03b-mode-selected-\(appearance)")

        let modeContinue = app.buttons["Continue"]
        if modeContinue.waitForExistence(timeout: 4), modeContinue.isEnabled {
            modeContinue.tap()
            _ = app.textFields.firstMatch.waitForExistence(timeout: 8)
            self.settle()
            self.snap(app, "04-manual-\(appearance)")
        }
    }

    func testCaptureSuccessStep() throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["OPENCLAW_ONBOARDING_SUCCESS_CAPTURE"] == "1",
            "Requires a live local gateway and CLI-side pairing approval")

        for appearance in ["light", "dark"] {
            self.app?.terminate()
            let app = XCUIApplication()
            app.launchArguments += [
                "--openclaw-reset-onboarding",
                "--openclaw-appearance",
                appearance,
            ]
            addUIInterruptionMonitor(withDescription: "Local network access") { alert in
                guard alert.buttons["Allow"].exists else { return false }
                alert.buttons["Allow"].tap()
                return true
            }
            app.launch()
            self.app = app

            XCTAssertTrue(app.buttons["Continue"].waitForExistence(timeout: 10))
            app.buttons["Continue"].tap()
            app.tap()
            XCTAssertTrue(app.buttons["Set up manually"].waitForExistence(timeout: 8))
            app.buttons["Set up manually"].tap()

            // The Apple Review demo setup code exercises the real success path
            // without needing a reachable gateway.
            let setupField = app.textFields["Paste setup code"]
            XCTAssertTrue(setupField.waitForExistence(timeout: 8))
            setupField.tap()
            setupField.typeText("APPLE-REVIEW-DEMO")
            if app.buttons["Done"].waitForExistence(timeout: 3) {
                app.buttons["Done"].tap()
            }
            let apply = app.buttons["Apply Setup Code"]
            XCTAssertTrue(apply.waitForExistence(timeout: 4))
            apply.tap()

            let connected = app.staticTexts["You’re connected"]
            XCTAssertTrue(connected.waitForExistence(timeout: 30))
            self.settle()
            self.snap(app, "05-success-\(appearance)")
        }
    }

    private func settle() {
        Thread.sleep(forTimeInterval: 0.8)
    }

    private func snap(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
