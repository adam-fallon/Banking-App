import XCTest
@testable import TCABankingApp

final class DateTests: XCTestCase {
    let userCalendar = Calendar(identifier: .gregorian)
    
    private func makeDate(year: Int, month: Int, day: Int) throws -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
                
        guard let date = userCalendar.date(from: dateComponents) else {
            throw Date.DateError.couldntMakeDate
        }
        
        return date
    }
    
    func testWeekAgo() throws {
        let now = Date()
        let weekRange = now.betweenWeekAgoAndNow()
        
        var dateComponent = DateComponents()
        dateComponent.day = -7
        
        XCTAssertEqual(weekRange.lowerBound, userCalendar.date(byAdding: dateComponent, to: weekRange.upperBound))
        
        // Boundaries of months
        let endOfMonth = try makeDate(year: 2023, month: 1, day: 1)
        let endOfMonthWeekRange = endOfMonth.betweenWeekAgoAndNow()
        
        XCTAssertEqual(endOfMonthWeekRange.lowerBound, userCalendar.date(byAdding: dateComponent, to: endOfMonthWeekRange.upperBound))
        
        // Invalid Date - 10 days in calendar were skipped in 1582 after the Council of Trent asked the Pope to make a new calendar.
        // https://www.britannica.com/story/ten-days-that-vanished-the-switch-to-the-gregorian-calendar
        // Technically the 5th October - 14th October of that year don't exist in the Gregorian calendar
        // This should technically work because we don't care what the days are, just that there is an interval of 7 days
        let invalidDate = try makeDate(year: 1582, month: 10, day: 5)
        let invalidDateWeekRange = invalidDate.betweenWeekAgoAndNow()
        
        XCTAssertEqual(invalidDateWeekRange.lowerBound, userCalendar.date(byAdding: dateComponent, to: invalidDateWeekRange.upperBound))
    }
}
