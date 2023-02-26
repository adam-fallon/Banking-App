import Foundation

extension Date {
    enum DateError: Error {
        case couldntMakeDate
    }
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }
    
    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
    
    func weekInterval() -> DateInterval {
        let week = self.betweenWeekAgoAndNow()
        return DateInterval(start: week.lowerBound, end: week.upperBound)
    }

    func betweenWeekAgoAndNow() -> ClosedRange<Date> {
        let calendar = Calendar.current
        
        if let weekAgo = calendar.date(byAdding: .day, value: -7, to: self) {
            return weekAgo...self
        } else {
            // What can you really do here, you've broken the OS calendar at this point
            return self...self
        }
    }
}
