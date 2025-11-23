import Foundation

// MARK: - Domain repository protocols
protocol CycleRepository {
    func create(_ cycle: Cycle) async throws -> Cycle
    func update(_ cycle: Cycle) async throws -> Cycle
    func fetchActiveCycle(for userId: String) async throws -> Cycle?
    func fetchAll(for userId: String) async throws -> [Cycle]
}

protocol SupplementRepository {
    func catalog() async throws -> [Supplement]
}

protocol IntakeRepository {
    func log(_ intake: IntakeLog) async throws
    func fetch(from: Date, to: Date, userId: String) async throws -> [IntakeLog]
}

protocol InventoryRepository {
    func load(userId: String) async throws -> [InventoryItem]
    func upsert(_ item: InventoryItem) async throws
}

// Invite-only social graph
protocol SocialRepository {
    func follow(_ followerId: String, _ followeeId: String) async throws
    func unfollow(_ followerId: String, _ followeeId: String) async throws
    func following(of userId: String) async throws -> [String]
    func feed(for userId: String) async throws -> [Post]
}