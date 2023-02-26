import Foundation
import XCTest

protocol PageObject {
    var app: XCUIApplication { get }
    var isShowing: Bool { get }
}
