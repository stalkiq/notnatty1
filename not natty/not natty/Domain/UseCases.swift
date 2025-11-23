import Foundation

struct CreateCyclePlan {
    let cycleRepo: CycleRepository
    var now: () -> Date = Date.init

    func callAsFunction(
        userId: String,
        name: String,
        startDate: Date,
        durationWeeks: Int,
        goals: [String],
        supplementPlans: [SupplementPlan],
        notes: String?
    ) async throws -> Cycle {
        let end = Calendar.current.date(byAdding: .weekOfYear, value: durationWeeks, to: startDate)
        let compounds: [CycleCompound] = supplementPlans.map { plan in
            CycleCompound(
                id: UUID().uuidString,
                cycleId: "",
                compoundId: plan.supplement.name,
                dosageMg: plan.dosageInMg,
                frequencyDays: plan.frequencyDays,
                startDate: startDate,
                endDate: end,
                notes: plan.notes.isEmpty ? nil : plan.notes,
                createdAt: now()
            )
        }

        let cycle = Cycle(
            id: UUID().uuidString,
            userId: userId,
            name: name,
            startDate: startDate,
            endDate: end,
            goals: goals,
            compounds: compounds,
            notes: notes,
            status: .planned,
            createdAt: now(),
            updatedAt: now()
        )
        return try await cycleRepo.create(cycle)
    }
}







