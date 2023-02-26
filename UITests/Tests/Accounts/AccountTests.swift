//
//  AccountTests.swift
//  UITests
//
//  Created by user on 14/01/2023.
//

import XCTest

final class AccountTests: BaseTestCase {

    override func setUp() {
        super.launchArgs.append("UserWithSingleAccount")
        super.launchArgs.append("AccountServiceWithTransaction")
        // super.launchArgs.append("AccountServiceWithOnlyInTransactions")
        super.setUp()
    }
    
    func testAccountShowingHappyPath() {
        let accounts = login()
        XCTAssertTrue(accounts.isShowing)
        let transactions = accounts.selectAccount("name - currency")
        XCTAssertTrue(transactions.isShowing)
    }
    
    func testAccountRoundUpChangeDate() {
        let accounts = login()
        XCTAssertTrue(accounts.isShowing)
        let transactions = accounts.selectAccount("name - currency")
        XCTAssertTrue(transactions.isShowing)
        
        transactions.changeDate(Date().betweenWeekAgoAndNow().lowerBound)
        
        // We've mocked a feed item of 1p, so round up should be 99p
        XCTAssertEqual(transactions.roundUpAmount.label, "£0.99")
        
        // transactions.roundUpButton.tap()
    }
    
}

extension AccountTests {
    private func login() -> AccountPage {
        let login = LoginPage(app: self.app)
        XCTAssertTrue(login.isShowing)
        
        let accounts = login
                .typeAccessToken("myToken")
                .tapLogin()
        
        return accounts
    }
}
