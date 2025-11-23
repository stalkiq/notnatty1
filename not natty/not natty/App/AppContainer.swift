//
//  AppContainer.swift
//  not natty
//

import Foundation

// MARK: - Dependency container (value type)
struct AppContainer {
    let config: AppConfig
    // Services
    let unitConverter: UnitConverter
    let csvExporter: CSVExporter
    let moderator: Moderator
    let notificationScheduler: NotificationScheduler
    // Repositories
    let cycleRepository: CycleRepository
    let supplementRepository: SupplementRepository
    let intakeRepository: IntakeRepository
    let inventoryRepository: InventoryRepository
    let socialRepository: SocialRepository

    // Use Cases (exposed factories where convenient)
    var createCyclePlan: CreateCyclePlan { .init(cycleRepo: cycleRepository) }

    static func live() -> AppContainer {
        let config = AppConfig(region: .us, dheaEnabled: false)
        let unit = UnitConverterImpl()
        let csv = CSVExporterImpl()
        let moderator = KeywordModerator(banned: ContentModeration.bannedTerms)
        let notifier = LocalNotificationScheduler()

        let cycleRepo = CycleRepositoryAPI()
        let supplementRepo = SupplementRepositoryLocal()
        let intakeRepo = IntakeRepositoryLocal()
        let inventoryRepo = InventoryRepositoryLocal()
        let socialRepo = SocialRepositoryLocal(postsSource: { [] })

        return AppContainer(
            config: config,
            unitConverter: unit,
            csvExporter: csv,
            moderator: moderator,
            notificationScheduler: notifier,
            cycleRepository: cycleRepo,
            supplementRepository: supplementRepo,
            intakeRepository: intakeRepo,
            inventoryRepository: inventoryRepo,
            socialRepository: socialRepo
        )
    }
}

// MARK: - App Configuration & Flags
struct AppConfig {
    enum Region { case us, eu, other }
    let region: Region
    let dheaEnabled: Bool
}




