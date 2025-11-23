//
//  SupplementsManager.swift
//  not natty
//
//  Loads and manages the legal supplement catalog. Seeds a local JSON on first run.
//

import Foundation

@MainActor
class SupplementsManager: ObservableObject {
    @Published var catalog: [Supplement] = []
    @Published var dheaEnabled: Bool = false
    @Published var intakes: [IntakeLog] = []
    @Published var inventory: [InventoryItem] = []
    
    private let fileName = "SupplementCatalog.json"
    private let quickLogKey = "quickLogNames"
    
    func ensureCatalogLoaded() {
        do {
            try seedIfNeeded()
            try loadCatalog()
        } catch {
            // Fallback: try to decode from embedded seed directly
            if let data = SupplementsManager.embeddedSeed.data(using: .utf8) {
                if let decoded = try? JSONDecoder().decode(SupplementCatalog.self, from: data) {
                    catalog = Self.applyGating(decoded.supplements, dheaEnabled: dheaEnabled)
                }
            }
        }
    }
    
    var quickLogItems: [Supplement] {
        // If user customized, use stored names, otherwise defaults from catalog flags
        if let names = UserDefaults.standard.array(forKey: quickLogKey) as? [String], !names.isEmpty {
            return catalog.filter { names.contains($0.name) }
        }
        return catalog.filter { $0.showInQuickLog == true }
    }
    
    func setQuickLog(names: [String]) {
        UserDefaults.standard.set(Array(Set(names)), forKey: quickLogKey)
        objectWillChange.send()
    }
    
    func toggleQuickLog(name: String) {
        var set = Set((UserDefaults.standard.array(forKey: quickLogKey) as? [String]) ?? quickLogItems.map { $0.name })
        if set.contains(name) { set.remove(name) } else { set.insert(name) }
        UserDefaults.standard.set(Array(set), forKey: quickLogKey)
        objectWillChange.send()
    }
    
    // MARK: - Intake API
    func logIntake(supplement: Supplement, amount: Double, unit: String, time: Date = Date(), note: String?) {
        guard supplement.allowedUnits.contains(unit) else { return }
        let log = IntakeLog(id: UUID().uuidString, supplementName: supplement.name, amount: amount, unit: unit, time: time, note: note)
        intakes.insert(log, at: 0)
        decrementInventory(for: supplement.name, amount: amount, unit: unit)
    }
    
    // MARK: - Inventory helpers (very light normalization for demo)
    private func decrementInventory(for supplementName: String, amount: Double, unit: String) {
        guard let idx = inventory.firstIndex(where: { $0.supplementName == supplementName }) else { return }
        // Only decrement if units match
        if inventory[idx].remainingUnit == unit, let current = inventory[idx].remainingAmount {
            inventory[idx].remainingAmount = max(0, current - amount)
        }
    }
    
    // MARK: - Private
    private func seedIfNeeded() throws {
        let url = try catalogFileURL()
        let fm = FileManager.default
        if !fm.fileExists(atPath: url.path) {
            // Write embedded seed
            let data = Data(Self.embeddedSeed.utf8)
            try fm.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: url, options: .atomic)
        }
    }
    
    private func loadCatalog() throws {
        let url = try catalogFileURL()
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(SupplementCatalog.self, from: data)
        catalog = Self.applyGating(decoded.supplements, dheaEnabled: dheaEnabled)
    }
    
    private func catalogFileURL() throws -> URL {
        let base = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return base.appendingPathComponent(fileName)
    }
    
    private static func applyGating(_ supplements: [Supplement], dheaEnabled: Bool) -> [Supplement] {
        supplements.filter { s in
            if s.name.lowercased() == "dhea" { return dheaEnabled }
            if s.requiresDHEAEnabled == true { return dheaEnabled }
            return true
        }
    }
    
    // Embedded seed catalog (legal supplements only). Non-medical educational UI ranges.
    // Keep in sync with README/Store metadata.
    static let embeddedSeed: String = """
    {"supplements":[
        {"name":"Whey Protein","forms":["powder"],"allowedUnits":["g","serving"],"typicalServing":{"unit":"g","min":20,"max":40},"tags":["protein","recovery"],"showInQuickLog":true},
        {"name":"Micellar Casein","brandExamples":["Kaged Micellar Casein"],"forms":["powder"],"allowedUnits":["g","serving"],"typicalServing":{"unit":"g","min":20,"max":40},"tags":["protein","night"]},
        {"name":"Mass Gainers","forms":["powder"],"allowedUnits":["g","serving"],"typicalServing":{"unit":"g","min":100,"max":200},"tags":["calories","carbs"]},
        {"name":"Creatine Monohydrate","forms":["powder","capsule"],"allowedUnits":["g","mg","serving"],"typicalServing":{"unit":"g","min":3,"max":5},"tags":["performance"],"showInQuickLog":true},
        {"name":"BCAAs","aka":"Branched-Chain Amino Acids","forms":["powder","capsule"],"allowedUnits":["g","serving"],"typicalServing":{"unit":"g","min":5,"max":10},"tags":["amino","intra-workout"]},
        {"name":"EAAs","aka":"Essential Amino Acids","forms":["powder","capsule"],"allowedUnits":["g","serving"],"typicalServing":{"unit":"g","min":5,"max":10},"tags":["amino"]},
        {"name":"Glutamine","forms":["powder","capsule"],"allowedUnits":["g","serving"],"typicalServing":{"unit":"g","min":3,"max":5},"tags":["recovery"]},
        {"name":"Beta-Alanine","forms":["powder","capsule"],"allowedUnits":["g","mg","serving"],"typicalServing":{"unit":"g","min":2,"max":5},"tags":["performance","preworkout"]},
        {"name":"Citrulline","forms":["powder","capsule"],"allowedUnits":["g","mg"],"typicalServing":{"unit":"g","min":3,"max":6},"tags":["pump","preworkout"]},
        {"name":"Arginine","forms":["powder","capsule"],"allowedUnits":["g","mg"],"typicalServing":{"unit":"g","min":3,"max":6},"tags":["pump","preworkout"]},
        {"name":"Betaine","forms":["powder","capsule"],"allowedUnits":["g","mg"],"typicalServing":{"unit":"g","min":1.5,"max":2.5},"tags":["performance"]},
        {"name":"HMB","aka":"Beta-hydroxy-beta-methylbutyrate","forms":["powder","capsule"],"allowedUnits":["g","mg"],"typicalServing":{"unit":"g","min":1.5,"max":3},"tags":["recovery"]},
        {"name":"Caffeine","forms":["tablet","capsule"],"allowedUnits":["mg","serving"],"typicalServing":{"unit":"mg","min":100,"max":300},"tags":["energy","preworkout"],"showInQuickLog":true},
        {"name":"Fish Oil","aka":"Omega-3 / Essential Fatty Acids","forms":["softgel"],"allowedUnits":["mg","serving"],"typicalServing":{"unit":"mg","min":1000,"max":2000},"tags":["health"]},
        {"name":"Vitamin D","forms":["softgel","tablet"],"allowedUnits":["IU","mcg"],"typicalServing":{"unit":"IU","min":1000,"max":4000},"tags":["health"]},
        {"name":"CoQ10","forms":["softgel","tablet"],"allowedUnits":["mg"],"typicalServing":{"unit":"mg","min":100,"max":200},"tags":["health"]},
        {"name":"Carnitine","forms":["liquid","capsule"],"allowedUnits":["g","mg"],"typicalServing":{"unit":"g","min":1,"max":2},"tags":["performance"]},
        {"name":"Multivitamins","forms":["tablet","capsule"],"allowedUnits":["serving"],"typicalServing":{"unit":"serving","min":1,"max":2},"tags":["health"]},
        {"name":"ZMA","forms":["capsule"],"allowedUnits":["serving"],"typicalServing":{"unit":"serving","min":1,"max":1},"tags":["sleep"]},
        {"name":"DHEA","forms":["tablet","capsule"],"allowedUnits":["mg"],"typicalServing":{"unit":"mg","min":25,"max":50},"tags":["hormone"],"requiresDHEAEnabled":true},
        {"name":"Essential Fatty Acids","forms":["softgel"],"allowedUnits":["mg","serving"],"typicalServing":{"unit":"mg","min":1000,"max":2000},"tags":["health"]}
    ]}
    """
}


