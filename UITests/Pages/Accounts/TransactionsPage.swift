import Foundation
import XCTest

struct TransactionPage: PageObject {
    var app: XCUIApplication
    
    private enum Identifiers {
        static let roundUpAmount = "transaction-roundUpAmount"
        static let roundUpButton = "transaction-roundUpButton"
        static let datePicker = "transaction-datePicker"
        static let transactionList = "transaction-list"
        static let loading = "transaction-loading"
        static let error = "transaction-error"
    }
    
    var isShowing: Bool {
        return app
            .staticTexts
            .matching(NSPredicate(format: "label CONTAINS 'Accounts'"))
            .firstMatch
            .exists
    }
    
    var datePicker: XCUIElement {
        return app.datePickers[Identifiers.datePicker]
    }
        
    func changeDate(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
                
        datePicker.tap()
        dateFormatter.string(from: date)
        app.buttons[dateFormatter.string(from: date)].tap()
        
        datePicker.tap()
    }
    
    var roundUpAmount: XCUIElement {
        return app.staticTexts[Identifiers.roundUpAmount]
    }
    
    var roundUpButton: XCUIElement {
        return app.buttons[Identifiers.roundUpButton]
    }
}

extension XCUIApplication {
    func tapCoordinate(at point: CGPoint) {
        let normalized = coordinate(withNormalizedOffset: .zero)
        let offset = CGVector(dx: point.x, dy: point.y)
        let coordinate = normalized.withOffset(offset)
        coordinate.tap()
    }
}
