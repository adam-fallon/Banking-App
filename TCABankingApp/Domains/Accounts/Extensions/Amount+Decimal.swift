import Foundation

extension Amount {
    var displayString: String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = self.currency.rawValue
        
        return currencyFormatter.string(from: self.toDecimal as NSNumber) ?? "NaN"
    }
    
    var toDecimal: Decimal {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currencyISOCode
        currencyFormatter.currencyCode = self.currency.rawValue
        
        return Decimal(self.minorUnits) / pow(10, currencyFormatter.minimumFractionDigits)
    }
}


extension Amount: Equatable {
    static func == (lhs: Amount, rhs: Amount) -> Bool {
        lhs.currency == rhs.currency && lhs.minorUnits == rhs.minorUnits
    }
}
