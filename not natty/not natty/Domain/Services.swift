import Foundation

protocol UnitConverter {
    func toBase(unit: String, amount: Double) -> (unit: String, amount: Double)
}

protocol CSVExporter {
    func intakesCSV(_ intakes: [IntakeLog]) -> Data
}

protocol Moderator {
    func isAllowed(text: String) -> Bool
}

protocol NotificationScheduler {
    func schedule(_ entries: [ReminderEntry]) async throws
}

struct ReminderEntry: Hashable {
    let id: String
    let title: String
    let body: String
    let date: Date
}







