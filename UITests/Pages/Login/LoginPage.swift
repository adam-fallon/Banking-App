import Foundation
import XCTest

struct LoginPage: PageObject {
    let app: XCUIApplication
    
    private enum Identifiers {
        static let accessToken = "accessToken"
        static let error = "error"
        static let login = "login"
    }
    
    var isShowing: Bool {
        return app
            .staticTexts
            .matching(NSPredicate(format: "label CONTAINS 'Login'"))
            .firstMatch
            .exists
    }
    
    func typeAccessToken(_ token: String) -> Self {
        let tokenField = app.secureTextFields[Identifiers.accessToken]
        tokenField.tap()
        tokenField.typeText(token)
        return self
    }
    
    func tapLogin() -> AccountPage {
        app.buttons[Identifiers.login].tap()
        return AccountPage(app: app)
    }
    
    var error: XCUIElement {
        return app.staticTexts[Identifiers.error]
    }
}
