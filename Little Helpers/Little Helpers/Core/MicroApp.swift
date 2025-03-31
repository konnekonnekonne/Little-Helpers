import Foundation

struct MicroApp: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let icon: String
    let description: String
    
    static let allApps: [MicroApp] = [
        MicroApp(
            id: "costSplit",
            name: "Cost Split",
            icon: "dollarsign.circle.fill",
            description: "Split expenses with friends and groups"
        ),
        MicroApp(
            id: "fitnessTimer",
            name: "Fitness Timer",
            icon: "timer",
            description: "Customizable workout timer with intervals"
        ),
        MicroApp(
            id: "toDoList",
            name: "To-Do List",
            icon: "checklist",
            description: "Simple and clean task management"
        ),
        MicroApp(
            id: "unitConverter",
            name: "Unit Converter",
            icon: "arrow.2.squarepath",
            description: "Convert between units like length, weight, temperature, and volume"
        ),
        MicroApp(
            id: "tipCalculator",
            name: "Tip Calculator",
            icon: "percent",
            description: "Calculate tips and split bills between people"
        ),
        MicroApp(
            id: "qrGenerator",
            name: "QR Code",
            icon: "qrcode",
            description: "Create and share QR codes for links, contact info, or text"
        ),
        MicroApp(
            id: "passwordGenerator",
            name: "Password Gen",
            icon: "key.fill",
            description: "Generate secure passwords with custom settings"
        ),
        MicroApp(
            id: "packingList",
            name: "Packing List",
            icon: "suitcase.fill",
            description: "Create and reuse packing lists for travel"
        ),
        MicroApp(
            id: "countdown",
            name: "Countdown",
            icon: "calendar.badge.clock",
            description: "Track important dates and upcoming events"
        ),
        MicroApp(
            id: "randomizer",
            name: "Randomizer",
            icon: "dice.fill",
            description: "Flip coins and roll dice with animations"
        ),
        MicroApp(
            id: "loanCalculator",
            name: "Loan Calc",
            icon: "banknote.fill",
            description: "Calculate loan payments and interest"
        ),
        MicroApp(
            id: "moodTracker",
            name: "Mood Log",
            icon: "face.smiling.fill",
            description: "Track your daily mood and see patterns"
        ),
        MicroApp(
            id: "timeZones",
            name: "Time Zones",
            icon: "globe",
            description: "View times across different cities"
        )
    ]
    
    // MARK: - Equatable
    
    static func == (lhs: MicroApp, rhs: MicroApp) -> Bool {
        lhs.id == rhs.id
    }
} 