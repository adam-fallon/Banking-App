import Foundation
import XCTest

struct AccountPage: PageObject {
    var app: XCUIApplication
    
    private enum Identifiers {
        static let accountList = "accountList"
        static let emptyAccounts = "emptyAccounts"
    }
    
    var isShowing: Bool {
        return app
            .staticTexts
            .matching(NSPredicate(format: "label CONTAINS 'Accounts'"))
            .firstMatch
            .exists
    }
    
    func account(_ named: String) -> XCUIElement {
        return app.buttons[named].firstMatch
    }
    
    func selectAccount(_ named: String) -> TransactionPage {
        account(named).tap()
        return TransactionPage(app: app)
    }
}
