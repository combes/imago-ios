//
//  ImagoUITests.swift
//  ImagoUITests
//
//  Created by Christopher Combes on 8/17/26.
//

import XCTest
@testable import Imago

final class ImagoUITests: XCTestCase {
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // Use sample data when testing UI
        app = XCUIApplication()
        app.launchArguments.append("--sampleData")
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    @MainActor
    func testSearch() throws {
        // 1. Locate the native search field
        let searchField = app.searchFields["Look for something"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        
        // 2. Tap the search bar to focus it
        searchField.tap()
        
        // 3. Type a search query
        searchField.typeText("Ligthouse")
        app.keyboards.buttons["Search"].tap()
        
        // 4. Count photo cells in photo grid by using count of `Image`
        let visibleImageCount = app.images.count
        XCTAssertEqual(6, visibleImageCount)
    }
}
