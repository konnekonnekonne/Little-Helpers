import Foundation

struct MicroApp: Identifiable, Codable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let price: Decimal
    var isPurchased: Bool
    var hasTried: Bool
    
    static let allApps: [MicroApp] = [
        MicroApp(
            id: "costSplit",
            name: "Cost Split",
            icon: "dollarsign.circle.fill",
            description: "Split expenses with friends and groups",
            price: 0.99,
            isPurchased: false,
            hasTried: false
        ),
        MicroApp(
            id: "fitnessTimer",
            name: "Fitness Timer",
            icon: "timer",
            description: "Customizable workout timer with intervals",
            price: 0.99,
            isPurchased: false,
            hasTried: false
        ),
        MicroApp(
            id: "toDoList",
            name: "To-Do List",
            icon: "checklist",
            description: "Simple and clean task management",
            price: 0.99,
            isPurchased: false,
            hasTried: false
        )
    ]
} 