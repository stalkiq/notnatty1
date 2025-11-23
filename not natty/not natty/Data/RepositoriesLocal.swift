import Foundation

// Simple in-memory / file-backed placeholders to fit existing app

final class SupplementRepositoryLocal: SupplementRepository {
    func catalog() async throws -> [Supplement] {
        // Bridge to existing SupplementsManager seed if desired
        // For now return an empty list; the UI already shows legal catalog via SupplementsManager
        return []
    }
}

final class IntakeRepositoryLocal: IntakeRepository {
    private var logs: [IntakeLog] = []
    func log(_ intake: IntakeLog) async throws { logs.append(intake) }
    func fetch(from: Date, to: Date, userId: String) async throws -> [IntakeLog] {
        logs.filter { $0.time >= from && $0.time <= to }
    }
}

final class InventoryRepositoryLocal: InventoryRepository {
    private var items: [InventoryItem] = []
    func load(userId: String) async throws -> [InventoryItem] { items }
    func upsert(_ item: InventoryItem) async throws {
        if let idx = items.firstIndex(where: { $0.id == item.id }) { items[idx] = item } else { items.append(item) }
    }
}

// Adapter to existing APIService for cycles (keeps behavior)
final class CycleRepositoryAPI: CycleRepository {
    func create(_ cycle: Cycle) async throws -> Cycle {
        try await APIService.shared.createCycle(
            name: cycle.name,
            startDate: cycle.startDate,
            goals: cycle.goals,
            compounds: cycle.compounds
        )
    }
    func update(_ cycle: Cycle) async throws -> Cycle { cycle }
    func fetchActiveCycle(for userId: String) async throws -> Cycle? {
        let all = try await APIService.shared.getCycles()
        return all.first { $0.status == .active }
    }
    func fetchAll(for userId: String) async throws -> [Cycle] {
        try await APIService.shared.getCycles()
    }
}

// MARK: - Social (invite-only) local repo
final class SocialRepositoryLocal: SocialRepository {
    private var followerToFollowing: [String: Set<String>] = [:]
    private var postsSource: () -> [Post]
    init(postsSource: @escaping () -> [Post]) { self.postsSource = postsSource }
    func follow(_ followerId: String, _ followeeId: String) async throws {
        var set = followerToFollowing[followerId] ?? []
        set.insert(followeeId)
        followerToFollowing[followerId] = set
    }
    func unfollow(_ followerId: String, _ followeeId: String) async throws {
        var set = followerToFollowing[followerId] ?? []
        set.remove(followeeId)
        followerToFollowing[followerId] = set
    }
    func following(of userId: String) async throws -> [String] {
        Array(followerToFollowing[userId] ?? [])
    }
    func feed(for userId: String) async throws -> [Post] {
        let followingIds = followerToFollowing[userId] ?? []
        return postsSource().filter { followingIds.contains($0.userId) || $0.userId == userId }
    }
}




