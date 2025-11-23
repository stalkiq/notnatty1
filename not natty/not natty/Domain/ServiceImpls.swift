import Foundation
import UserNotifications

struct UnitConverterImpl: UnitConverter {
    func toBase(unit: String, amount: Double) -> (unit: String, amount: Double) {
        switch unit.lowercased() {
        case "mg": return ("mg", amount)
        case "g": return ("mg", amount * 1000)
        default: return (unit, amount)
        }
    }
}

struct CSVExporterImpl: CSVExporter {
    func intakesCSV(_ intakes: [IntakeLog]) -> Data {
        var rows = ["Date,Time,Supplement,Amount,Unit,Note"]
        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"; let tf = DateFormatter(); tf.dateFormat = "HH:mm"
        for i in intakes {
            let row = "\(df.string(from: i.time)),\(tf.string(from: i.time)),\(i.supplementName),\(i.amount),\(i.unit),\(i.note ?? "")"
            rows.append(row)
        }
        return rows.joined(separator: "\n").data(using: .utf8) ?? Data()
    }
}

struct KeywordModerator: Moderator {
    let banned: [String]
    func isAllowed(text: String) -> Bool {
        let lowered = text.lowercased()
        return !banned.contains { lowered.contains($0) }
    }
}

struct LocalNotificationScheduler: NotificationScheduler {
    func schedule(_ entries: [ReminderEntry]) async throws {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        if settings.authorizationStatus != .authorized {
            try await center.requestAuthorization(options: [.alert, .sound, .badge])
        }
        for e in entries {
            let content = UNMutableNotificationContent()
            content.title = e.title
            content.body = e.body
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, e.date.timeIntervalSinceNow), repeats: false)
            let request = UNNotificationRequest(identifier: e.id, content: content, trigger: trigger)
            try await center.add(request)
        }
    }
}







