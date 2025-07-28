//
//  Cycle.swift
//  not natty
//
//  Created by Apple Id on 7/26/25.
//

import Foundation

struct Cycle: Identifiable, Codable {
    let id: String
    let userId: String
    let name: String
    let startDate: Date
    let endDate: Date?
    let goals: [String]
    let compounds: [CycleCompound]
    let notes: String?
    let status: CycleStatus
    let createdAt: Date
    let updatedAt: Date
    
    enum CycleStatus: String, Codable, CaseIterable {
        case planned = "planned"
        case active = "active"
        case completed = "completed"
        case cancelled = "cancelled"
        
        var displayName: String {
            switch self {
            case .planned: return "Planned"
            case .active: return "Active"
            case .completed: return "Completed"
            case .cancelled: return "Cancelled"
            }
        }
        
        var color: String {
            switch self {
            case .planned: return "blue"
            case .active: return "green"
            case .completed: return "gray"
            case .cancelled: return "red"
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case startDate = "start_date"
        case endDate = "end_date"
        case goals, compounds, notes, status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct CycleCompound: Identifiable, Codable {
    let id: String
    let cycleId: String
    let compoundId: String
    let dosageMg: Double?
    let frequencyDays: Int?
    let startDate: Date?
    let endDate: Date?
    let notes: String?
    let createdAt: Date
    
    var compound: Compound?
    
    enum CodingKeys: String, CodingKey {
        case id
        case cycleId = "cycle_id"
        case compoundId = "compound_id"
        case dosageMg = "dosage_mg"
        case frequencyDays = "frequency_days"
        case startDate = "start_date"
        case endDate = "end_date"
        case notes
        case createdAt = "created_at"
    }
}

struct Compound: Identifiable, Codable {
    let id: String
    let name: String
    let category: CompoundCategory
    let halfLifeHours: Int?
    let description: String?
    let isVerified: Bool
    let createdAt: Date
    
    enum CompoundCategory: String, Codable, CaseIterable {
        case testosterone = "testosterone"
        case anabolic = "anabolic"
        case peptide = "peptide"
        case sarm = "sarm"
        case other = "other"
        
        var displayName: String {
            switch self {
            case .testosterone: return "Testosterone"
            case .anabolic: return "Anabolic"
            case .peptide: return "Peptide"
            case .sarm: return "SARM"
            case .other: return "Other"
            }
        }
        
        var color: String {
            switch self {
            case .testosterone: return "blue"
            case .anabolic: return "red"
            case .peptide: return "green"
            case .sarm: return "purple"
            case .other: return "gray"
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, category
        case halfLifeHours = "half_life_hours"
        case description
        case isVerified = "is_verified"
        case createdAt = "created_at"
    }
}

struct Injection: Identifiable, Codable {
    let id: String
    let userId: String
    let cycleId: String?
    let compoundId: String?
    let compoundName: String
    let dosageMg: Double
    let injectionSite: InjectionSite?
    let injectionMethod: InjectionMethod?
    let needleGauge: Int?
    let needleLengthMm: Int?
    let notes: String?
    let injectedAt: Date
    let createdAt: Date
    
    enum InjectionSite: String, Codable, CaseIterable {
        case glute = "glute"
        case quad = "quad"
        case delt = "delt"
        case ventroglute = "ventroglute"
        case other = "other"
        
        var displayName: String {
            switch self {
            case .glute: return "Glute"
            case .quad: return "Quad"
            case .delt: return "Delt"
            case .ventroglute: return "Ventroglute"
            case .other: return "Other"
            }
        }
    }
    
    enum InjectionMethod: String, Codable, CaseIterable {
        case im = "im"
        case subq = "subq"
        
        var displayName: String {
            switch self {
            case .im: return "Intramuscular"
            case .subq: return "Subcutaneous"
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case cycleId = "cycle_id"
        case compoundId = "compound_id"
        case compoundName = "compound_name"
        case dosageMg = "dosage_mg"
        case injectionSite = "injection_site"
        case injectionMethod = "injection_method"
        case needleGauge = "needle_gauge"
        case needleLengthMm = "needle_length_mm"
        case notes
        case injectedAt = "injected_at"
        case createdAt = "created_at"
    }
}

struct SideEffect: Identifiable, Codable {
    let id: String
    let userId: String
    let cycleId: String?
    let symptoms: [String]
    let severity: Int
    let bloodPressureSystolic: Int?
    let bloodPressureDiastolic: Int?
    let moodRating: Int?
    let libidoRating: Int?
    let acneSeverity: Int?
    let notes: String?
    let recordedAt: Date
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case cycleId = "cycle_id"
        case symptoms, severity
        case bloodPressureSystolic = "blood_pressure_systolic"
        case bloodPressureDiastolic = "blood_pressure_diastolic"
        case moodRating = "mood_rating"
        case libidoRating = "libido_rating"
        case acneSeverity = "acne_severity"
        case notes
        case recordedAt = "recorded_at"
        case createdAt = "created_at"
    }
} 