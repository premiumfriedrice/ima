//
//  HabitFlowTests.swift
//  imaUITests
//
//  Created by Lloyd Derryk Mudanza Alba on 12/22/25.
//

import XCTest

final class HabitFlowTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCreateAndIncrementAndEditHabit() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()
        
        let uniqueTitle = "Test Habit \(Int(Date().timeIntervalSince1970))"

        // 1. Open Add Sheet
        let addButton = app.buttons["AddHabitButton"]
        if addButton.exists {
            addButton.tap()
        } else {
            app.navigationBars.buttons["Add"].tap()
        }

        // 2. Type Title
        let titleTextField = app.textFields["HabitTitleInput"]
        XCTAssertTrue(titleTextField.waitForExistence(timeout: 2))
        titleTextField.tap()
        titleTextField.typeText(uniqueTitle)
        
        // Try tapping the "Return" key if available, or tapping outside
        if app.keyboards.buttons["return"].exists {
            app.keyboards.buttons["return"].tap()
        }

        // 3. Save
        app.buttons["SaveHabitButton"].tap()

        // 4. Find the Card
        let specificHabitButton = app.buttons[uniqueTitle].firstMatch
        XCTAssertTrue(specificHabitButton.waitForExistence(timeout: 2))
        
        // ASSERT INITIAL STATE: Check the value we set in the View
        // Should be "0 out of 1" initially
        // Note: XCUITest reads accessibility values as Strings
        XCTAssertEqual(specificHabitButton.value as? String, "0 out of 1 today")

        // 5. Tap to Increment
        specificHabitButton.tap()

        // 6. ASSERT NEW STATE
        // We wait for the value to change (Animations take time)
        let donePredicate = NSPredicate(format: "value == 'Done'") // Matches our View logic
        
        let expectation = XCTNSPredicateExpectation(predicate: donePredicate, object: specificHabitButton)
        
        // Wait up to 2 seconds for the animation/state update to finish
        let result = XCTWaiter.wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(result, .completed, "Habit should be marked 'Done' after tapping")
        
        // Click on Info Button
        let infoSheetButton = app.buttons["InfoSheetButton"]
        infoSheetButton.tap()
        
        let countWheel = app.pickerWheels.element(boundBy: 0)
        if countWheel.exists {
            countWheel.adjust(toPickerWheelValue: "3")
        }

        // Adjust the Unit (Second Wheel) -> Scroll to "Weekly"
        let unitWheel = app.pickerWheels.element(boundBy: 1)
        if unitWheel.exists {
            unitWheel.adjust(toPickerWheelValue: "Week")
        }
        
        // 1. Close the Info/Edit Sheet
        app.buttons["CloseInfoViewButton"].tap()

        XCTAssertTrue(specificHabitButton.waitForExistence(timeout: 2))
        
        let updatedValue = specificHabitButton.value as? String ?? ""
        
        // Verify the Count AND the Period
        XCTAssertTrue(updatedValue.contains("1 out of 3"), "Count should be updated")
        XCTAssertTrue(updatedValue.contains("this week"), "Time period should be updated to 'this week'")
    }
}
