import Foundation

enum TipCalculatorMode: String, CaseIterable {
    case calculateTotal = "Calculate Total"
    case calculatePercentage = "Calculate Tip %"
}

struct QuickTipOption: Identifiable {
    let id = UUID()
    let percentage: Double
    
    var formatted: String {
        "\(Int(percentage))%"
    }
}

extension QuickTipOption {
    static let predefinedOptions: [QuickTipOption] = [
        .init(percentage: 3),
        .init(percentage: 5),
        .init(percentage: 7),
        .init(percentage: 10),
        .init(percentage: 15)
    ]
} 