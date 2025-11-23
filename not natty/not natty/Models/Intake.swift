//
//  Intake.swift
//  not natty
//
//  Created by AI on 8/15/25.
//

import Foundation

struct IntakeLog: Identifiable, Codable, Hashable {
    let id: String
    let supplementName: String
    let amount: Double
    let unit: String
    let time: Date
    let note: String?
}

struct InventoryItem: Identifiable, Codable, Hashable {
    let id: String
    let supplementName: String
    var containerSizeAmount: Double?
    var containerSizeUnit: String?
    var servingSizeAmount: Double?
    var servingSizeUnit: String?
    var remainingAmount: Double?
    var remainingUnit: String?
    var lowStockThresholdAmount: Double?
    var lowStockThresholdUnit: String?
}







