// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let transaction = try? JSONDecoder().decode(Transaction.self, from: jsonData)

import Foundation

// MARK: - Transaction
struct Transaction: Codable, Equatable, Identifiable {
    var id = UUID()
    let feedItems: [FeedItem]
    
    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        lhs.id == rhs.id
    }
    
    private enum CodingKeys: String, CodingKey {
        case feedItems
    }
}

// MARK: - FeedItem
struct FeedItem: Codable, Identifiable {
    var id: String {
        feedItemUid
    }
    
    let feedItemUid, categoryUid: String
    let amount, sourceAmount: Amount
    let direction: Direction
    let updatedAt, transactionTime, settlementTime: String
    let source: String
    let status: String
    let counterPartyType: CounterPartyType
    let counterPartyName: String
    let counterPartySubEntityName: String
    let counterPartySubEntityIdentifier, counterPartySubEntitySubIdentifier, reference: String
    let country: Country
    let spendingCategory: String
    let hasAttachment, hasReceipt: Bool
    let batchPaymentDetails: String?
    let transactingApplicationUserUid, counterPartyUid, counterPartySubEntityUid: String?
}

// MARK: - Amount
struct Amount: Codable {
    let currency: Currency
    let minorUnits: Int
}

enum Currency: String, Codable {
    case gbp = "GBP"
    case eur = "EUR"
}

enum CounterPartyType: String, Codable {
    case payee = "PAYEE"
    case sender = "SENDER"
}

enum Country: String, Codable {
    case gb = "GB"
}

enum Direction: String, Codable {
    // in is a keyword
    case directionIN = "IN"
    case out = "OUT"
}
