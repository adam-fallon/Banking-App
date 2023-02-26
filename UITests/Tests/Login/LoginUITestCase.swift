import XCTest

final class LoginUITestCase: BaseTestCase {
    override func setUp() {        
        super.setUp()
    }
    
    func testLoginHappyPath() {
        let login = LoginPage(app: self.app)
        XCTAssertTrue(login.isShowing)
        
        let accounts = login
                .typeAccessToken("myToken")
                .tapLogin()
        
        XCTAssertTrue(accounts.isShowing)
    }
    
    func testLoginShowsErrorWhenNoUserNamePasswordProvided() {
        let login = LoginPage(app: self.app)
        XCTAssertTrue(login.isShowing)
        
        let _ = login.tapLogin()
        
        XCTAssertTrue(login.error.exists)
        XCTAssertEqual(login.error.label, "Login failed.")
    }
    
    func testLoginShowsErrorForInvalidUser() {
        let login = LoginPage(app: self.app)
        XCTAssertTrue(login.isShowing)
        
        let _ = login
            .typeAccessToken("invalidToken")
            .tapLogin()
        
        XCTAssertTrue(login.error.exists)
        XCTAssertEqual(login.error.label, "Login failed.")
    }
    
}

final class LoginUITestCaseServiceDown: BaseTestCase {
    override func setUp() {
        super.launchArgs.append("UserServiceDown")
        super.setUp()
    }
    
    func testLoginShowsErrorWhenFailedToConnectToService() {
        let login = LoginPage(app: self.app)
        XCTAssertTrue(login.isShowing)
        
        let _ = login
            .typeAccessToken("myToken")
            .tapLogin()
        
        XCTAssertTrue(login.error.exists)
        XCTAssertEqual(login.error.label, "Oops, something went wrong. Please try again.")
    }
}
