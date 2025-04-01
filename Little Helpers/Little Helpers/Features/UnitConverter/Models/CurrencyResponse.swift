import Foundation

struct CurrencyResponse: Codable {
    let rates: [String: Double]
    let base: String
    let date: String
} 