import Foundation

enum UnitType: String, CaseIterable, Identifiable, Hashable {
    case currency = "Currency"
    case weight = "Weight"
    case volume = "Volume"
    case length = "Length"
    case temperature = "Temperature"
    
    var id: Self { self }
    
    var emoji: String {
        switch self {
        case .currency: return "💰"
        case .weight: return "🏋️"
        case .volume: return "🧪"
        case .length: return "📏"
        case .temperature: return "🌡️"
        }
    }
    
    var name: String {
        return rawValue
    }
}

struct Unit: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let symbol: String
    let type: UnitType
    let conversionFactor: Double
    
    static var currencyUnits: [Unit] = [
        Unit(name: "US Dollar", symbol: "$", type: .currency, conversionFactor: 1.0),
        Unit(name: "Euro", symbol: "€", type: .currency, conversionFactor: 0.92),
        Unit(name: "British Pound", symbol: "£", type: .currency, conversionFactor: 0.79),
        Unit(name: "Japanese Yen", symbol: "¥", type: .currency, conversionFactor: 151.5),
        Unit(name: "Swiss Franc", symbol: "Fr", type: .currency, conversionFactor: 0.91)
    ]
    
    static let standardUnits: [UnitType: [Unit]] = [
        .weight: [
            Unit(name: "Kilogram", symbol: "kg", type: .weight, conversionFactor: 1.0),      // Base unit
            Unit(name: "Pound", symbol: "lb", type: .weight, conversionFactor: 2.20462),      // 1 kg = 2.20462 lb
            Unit(name: "Ounce", symbol: "oz", type: .weight, conversionFactor: 35.274),       // 1 kg = 35.274 oz
            Unit(name: "Gram", symbol: "g", type: .weight, conversionFactor: 1000.0)          // 1 kg = 1000 g
        ],
        .volume: [
            Unit(name: "Liter", symbol: "L", type: .volume, conversionFactor: 1.0),           // Base unit
            Unit(name: "Milliliter", symbol: "mL", type: .volume, conversionFactor: 1000.0),  // 1 L = 1000 mL
            Unit(name: "Cup", symbol: "cup", type: .volume, conversionFactor: 4.22675),       // 1 L = 4.22675 cups
            Unit(name: "Gallon", symbol: "gal", type: .volume, conversionFactor: 0.264172),   // 1 L = 0.264172 gal
            Unit(name: "Fluid Ounce", symbol: "fl oz", type: .volume, conversionFactor: 33.814) // 1 L = 33.814 fl oz
        ],
        .length: [
            Unit(name: "Meter", symbol: "m", type: .length, conversionFactor: 1.0),           // Base unit
            Unit(name: "Centimeter", symbol: "cm", type: .length, conversionFactor: 100.0),   // 1 m = 100 cm
            Unit(name: "Millimeter", symbol: "mm", type: .length, conversionFactor: 1000.0),  // 1 m = 1000 mm
            Unit(name: "Foot", symbol: "ft", type: .length, conversionFactor: 3.28084),       // 1 m = 3.28084 ft
            Unit(name: "Inch", symbol: "in", type: .length, conversionFactor: 39.3701)        // 1 m = 39.3701 in
        ],
        .temperature: [
            Unit(name: "Celsius", symbol: "°C", type: .temperature, conversionFactor: 1.0),
            Unit(name: "Fahrenheit", symbol: "°F", type: .temperature, conversionFactor: 1.0),
            Unit(name: "Kelvin", symbol: "K", type: .temperature, conversionFactor: 1.0)
        ]
    ]
    
    static func getUnits(for type: UnitType) -> [Unit] {
        if type == .currency {
            return currencyUnits
        }
        return standardUnits[type] ?? []
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Unit, rhs: Unit) -> Bool {
        lhs.id == rhs.id
    }
} 