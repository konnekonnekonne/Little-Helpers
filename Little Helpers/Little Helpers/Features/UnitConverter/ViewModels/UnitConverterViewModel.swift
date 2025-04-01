import Foundation

class UnitConverterViewModel: ObservableObject {
    @Published var selectedType: UnitType = .currency {
        didSet {
            setDefaultUnits()
            if selectedType == .currency {
                updateCurrencyRatesIfNeeded()
            }
        }
    }
    @Published var inputValue: String = "1"
    @Published var fromUnit: Unit?
    @Published var toUnit: Unit?
    @Published var isOffline: Bool = false
    @Published var lastUpdated: Date?
    @Published var isRefreshing: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let lastUpdateKey = "lastCurrencyUpdate"
    private let currencyRatesKey = "currencyRates"
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    init() {
        loadLastUpdateTime()
        setDefaultUnits()
        if selectedType == .currency {
            updateCurrencyRatesIfNeeded()
        }
    }
    
    func refreshCurrencyRates() {
        guard !isRefreshing else { return }
        isRefreshing = true
        fetchCurrencyRates()
    }
    
    private func setDefaultUnits() {
        let units = Unit.getUnits(for: selectedType)
        
        switch selectedType {
        case .currency:
            fromUnit = units.first { $0.symbol == "€" }  // EUR
            toUnit = units.first { $0.symbol == "$" }    // USD
        case .weight:
            fromUnit = units.first { $0.symbol == "kg" } // Kilogram
            toUnit = units.first { $0.symbol == "lb" }   // Pound
        case .volume:
            fromUnit = units.first { $0.symbol == "L" }  // Liter
            toUnit = units.first { $0.symbol == "gal" }  // Gallon
        case .length:
            fromUnit = units.first { $0.symbol == "m" }  // Meter
            toUnit = units.first { $0.symbol == "ft" }   // Foot
        case .temperature:
            fromUnit = units.first { $0.symbol == "°C" } // Celsius
            toUnit = units.first { $0.symbol == "°F" }   // Fahrenheit
        }
        
        // Ensure input value is set to 1
        if inputValue.isEmpty {
            inputValue = "1"
        }
    }
    
    private func loadLastUpdateTime() {
        if let lastUpdate = userDefaults.object(forKey: lastUpdateKey) as? Date {
            lastUpdated = lastUpdate
        }
    }
    
    func updateCurrencyRatesIfNeeded() {
        guard selectedType == .currency else { return }
        
        let now = Date()
        if let lastUpdate = lastUpdated,
           now.timeIntervalSince(lastUpdate) < 24 * 60 * 60 {
            // Load cached rates
            if let rates = userDefaults.dictionary(forKey: currencyRatesKey) as? [String: Double] {
                updateCurrencyUnits(with: rates)
            }
            return // Less than 24 hours since last update
        }
        
        fetchCurrencyRates()
    }
    
    private func fetchCurrencyRates() {
        guard let url = URL(string: "https://api.exchangerate.host/latest?base=USD") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let rates = try? JSONDecoder().decode(CurrencyResponse.self, from: data) else {
                DispatchQueue.main.async {
                    self?.isOffline = true
                    self?.isRefreshing = false
                }
                return
            }
            
            DispatchQueue.main.async {
                self.updateCurrencyUnits(with: rates.rates)
                self.lastUpdated = Date()
                self.userDefaults.set(self.lastUpdated, forKey: self.lastUpdateKey)
                self.userDefaults.set(rates.rates, forKey: self.currencyRatesKey)
                self.isOffline = false
                self.isRefreshing = false
                // Reapply default units after updating rates
                self.setDefaultUnits()
            }
        }.resume()
    }
    
    private func updateCurrencyUnits(with rates: [String: Double]) {
        var updatedUnits = Unit.currencyUnits
        for (index, unit) in updatedUnits.enumerated() {
            if let rate = rates[unit.symbol] {
                updatedUnits[index] = Unit(
                    name: unit.name,
                    symbol: unit.symbol,
                    type: .currency,
                    conversionFactor: rate
                )
            }
        }
        Unit.currencyUnits = updatedUnits
    }
    
    func convert() -> Double? {
        guard let fromUnit = fromUnit,
              let toUnit = toUnit,
              let inputValue = Double(inputValue) else {
            return nil
        }
        
        switch selectedType {
        case .temperature:
            return convertTemperature(from: fromUnit, to: toUnit, value: inputValue)
        default:
            // First convert to base unit, then to target unit
            let baseValue = inputValue / fromUnit.conversionFactor
            return baseValue * toUnit.conversionFactor
        }
    }
    
    private func convertTemperature(from: Unit, to: Unit, value: Double) -> Double {
        // Convert to Celsius first
        let celsius: Double
        switch from.symbol {
        case "°F":
            celsius = (value - 32) * 5/9
        case "K":
            celsius = value - 273.15
        default: // °C
            celsius = value
        }
        
        // Convert from Celsius to target unit
        switch to.symbol {
        case "°F":
            return (celsius * 9/5) + 32
        case "K":
            return celsius + 273.15
        default: // °C
            return celsius
        }
    }
    
    func swapUnits() {
        let temp = fromUnit
        fromUnit = toUnit
        toUnit = temp
    }
    
    func formatLastUpdated() -> String? {
        guard let lastUpdated = lastUpdated else { return nil }
        return dateFormatter.string(from: lastUpdated)
    }
    
    func formatResult(_ value: Double) -> String {
        if value >= 1_000_000 || value <= 0.00001 {
            return String(format: "%.2e", value)
        } else {
            return String(format: "%.2f", value)
        }
    }
} 