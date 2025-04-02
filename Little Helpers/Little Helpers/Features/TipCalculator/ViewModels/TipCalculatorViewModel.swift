import Foundation

@MainActor
class TipCalculatorViewModel: ObservableObject {
    @Published var mode: TipCalculatorMode = .calculateTotal
    @Published var billAmount: String = ""
    @Published var tipPercentage: Double = 10.0
    @Published var totalAmount: String = ""
    
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    var currencySymbol: String {
        currencyFormatter.currencySymbol ?? "€"
    }
    
    var quickTipOptions: [QuickTipOption] {
        QuickTipOption.predefinedOptions
    }
    
    // MARK: - Computed Properties
    
    var billAmountValue: Double {
        Double(billAmount.replacingOccurrences(of: ",", with: ".")) ?? 0
    }
    
    var totalAmountValue: Double {
        Double(totalAmount.replacingOccurrences(of: ",", with: ".")) ?? 0
    }
    
    var tipAmount: Double {
        switch mode {
        case .calculateTotal:
            return billAmountValue * (tipPercentage / 100)
        case .calculatePercentage:
            return totalAmountValue - billAmountValue
        }
    }
    
    var calculatedTotal: Double {
        switch mode {
        case .calculateTotal:
            return billAmountValue + tipAmount
        case .calculatePercentage:
            return totalAmountValue
        }
    }
    
    var calculatedPercentage: Double {
        guard billAmountValue > 0 else { return 0 }
        return (tipAmount / billAmountValue) * 100
    }
    
    // MARK: - Formatting
    
    func formatCurrency(_ amount: Double) -> String {
        if amount == 0 && (billAmount.isEmpty || totalAmount.isEmpty) {
            return ""
        }
        return currencyFormatter.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
    }
    
    func formatPercentage(_ percentage: Double) -> String {
        String(format: "%.1f%%", percentage)
    }
    
    // MARK: - Actions
    
    func setQuickTip(_ option: QuickTipOption) {
        tipPercentage = option.percentage
    }
    
    func handleNumberInput(_ text: String, for field: inout String) {
        // Remove any non-numeric characters
        let numbers = text.filter { $0.isNumber }
        
        // Convert to a decimal number (divide by 100 to handle cents)
        if let value = Double(numbers) {
            let decimalValue = value / 100.0
            field = formatCurrency(decimalValue)
        } else if text.isEmpty {
            field = ""
        }
    }
} 