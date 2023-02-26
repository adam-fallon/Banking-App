import XCTest

struct SavingsPage: PageObject {
    var app: XCUIApplication
    
    private enum Identifiers {
        static let accountList = "accountList"
        static let emptyAccounts = "emptyAccounts"
    }
    
    var isShowing: Bool {
        return app
            .staticTexts
            .matching(NSPredicate(format: "label CONTAINS 'Savings'"))
            .firstMatch
            .exists
    }
}

