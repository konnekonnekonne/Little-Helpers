import Foundation

struct CountdownEvent: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var date: Date
    var hasCustomTime: Bool
    var createdAt: Date
    
    init(id: UUID = UUID(), title: String, date: Date, hasCustomTime: Bool = false) {
        self.id = id
        self.title = title
        self.date = hasCustomTime ? date : Calendar.current.startOfDay(for: date)
        self.hasCustomTime = hasCustomTime
        self.createdAt = Date()
    }
    
    var isCompleted: Bool {
        Date() >= date
    }
    
    func shouldShowSeconds(currentDate: Date = Date()) -> Bool {
        let components = timeComponents(currentDate: currentDate)
        return components.days == 0
    }
    
    func timeComponents(currentDate: Date = Date()) -> (isNegative: Bool, days: Int, hours: Int, minutes: Int, seconds: Int, totalSeconds: Int) {
        let calendar = Calendar.current
        let components: DateComponents
        let isNegative = currentDate >= date
        
        if isNegative {
            components = calendar.dateComponents([.day, .hour, .minute, .second], from: date, to: currentDate)
        } else {
            components = calendar.dateComponents([.day, .hour, .minute, .second], from: currentDate, to: date)
        }
        
        let days = abs(components.day ?? 0)
        let hours = abs(components.hour ?? 0)
        let minutes = abs(components.minute ?? 0)
        let seconds = abs(components.second ?? 0)
        let totalSeconds = days * 86400 + hours * 3600 + minutes * 60 + seconds
        
        return (
            isNegative: isNegative,
            days: days,
            hours: hours,
            minutes: minutes,
            seconds: seconds,
            totalSeconds: totalSeconds
        )
    }
    
    var formattedTimeRemaining: String {
        let time = timeComponents()
        let prefix = time.isNegative ? "-" : ""
        return "\(prefix)\(String(format: "%02d", time.days)):\(String(format: "%02d", time.hours)):\(String(format: "%02d", time.minutes)):\(String(format: "%02d", time.seconds))"
    }
    
    static func == (lhs: CountdownEvent, rhs: CountdownEvent) -> Bool {
        lhs.id == rhs.id
    }
} 