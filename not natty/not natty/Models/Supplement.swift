//
//  Supplement.swift
//  not natty
//
//  Created by AI on 8/15/25.
//

import Foundation

struct SupplementCatalog: Codable {
    let supplements: [Supplement]
}

struct Supplement: Identifiable, Codable, Hashable {
    var id: String { name }
    let name: String
    let aka: String?
    let brandExamples: [String]?
    let forms: [String]
    let allowedUnits: [String]
    let typicalServing: TypicalServing
    let tags: [String]?
    let requiresDHEAEnabled: Bool?
    let showInQuickLog: Bool?
}

struct TypicalServing: Codable, Hashable {
    let unit: String
    let min: Double
    let max: Double
}

// Cycle planning structures (local/app-only)
struct SupplementPlan: Identifiable, Hashable {
    let id: String = UUID().uuidString
    var supplement: Supplement
    var dosage: Double
    var unit: String
    var frequencyDays: Int
    var notes: String
    
    init(supplement: Supplement) {
        self.supplement = supplement
        self.dosage = max(supplement.typicalServing.min, (supplement.typicalServing.min + supplement.typicalServing.max) / 2)
        self.unit = supplement.typicalServing.unit
        self.frequencyDays = 1
        self.notes = ""
    }
    
    var dosageInMg: Double? {
        if unit.lowercased() == "mg" { return dosage }
        if unit.lowercased() == "g" { return dosage * 1000 }
        return nil
    }
}


