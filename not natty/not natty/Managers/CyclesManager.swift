//
//  CyclesManager.swift
//  Not Natty
//
//  Created by Apple Id on 7/26/25.
//  Copyright © 2025 Not Natty. All rights reserved.
//

/**
 * Cycles Manager
 * 
 * Manages steroid cycle tracking, injection logging, side effect monitoring,
 * and compound database. Handles all cycle-related functionality in the
 * Not Natty app.
 */

import Foundation
import SwiftUI

@MainActor
class CyclesManager: ObservableObject {
    @Published var cycles: [Cycle] = []
    @Published var injections: [Injection] = []
    @Published var sideEffects: [SideEffect] = []
    @Published var compounds: [Compound] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var authManager: AuthManager?
    
    func setAuthManager(_ authManager: AuthManager) {
        self.authManager = authManager
    }
    
    // MARK: - Cycle Management
    
    func fetchCycles() async {
        isLoading = true
        errorMessage = nil
        
        do {
            cycles = try await APIService.shared.getCycles()
            injections = try await APIService.shared.getInjections()
            sideEffects = try await APIService.shared.getSideEffects()
            // TODO: Add compounds API endpoint
            compounds = sampleCompounds
            
        } catch {
            errorMessage = "Failed to load cycles: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func createCycle(name: String, startDate: Date, goals: [String], compounds: [CycleCompound], notes: String?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newCycle = try await APIService.shared.createCycle(
                name: name,
                description: nil,
                startDate: startDate,
                endDate: nil,
                goals: goals,
                notes: notes
            )
            
            cycles.append(newCycle)
            
        } catch {
            errorMessage = "Failed to create cycle: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func logInjection(compoundName: String, dosageMg: Double, injectionSite: Injection.InjectionSite?, injectionMethod: Injection.InjectionMethod?, cycleId: String?, notes: String?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // For now, use a placeholder compound ID - in a real app, you'd look up the compound by name
            let compoundId = "placeholder-compound-id"
            
            let newInjection = try await APIService.shared.createInjection(
                compoundId: compoundId,
                dosage: dosageMg,
                injectionSite: injectionSite?.rawValue ?? "Not specified",
                injectedAt: Date(),
                cycleId: cycleId,
                notes: notes
            )
            
            injections.insert(newInjection, at: 0)
            
        } catch {
            errorMessage = "Failed to log injection: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func logSideEffect(symptoms: [String], severity: Int, bloodPressureSystolic: Int?, bloodPressureDiastolic: Int?, moodRating: Int?, libidoRating: Int?, acneSeverity: Int?, notes: String?, cycleId: String?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newSideEffect = try await APIService.shared.createSideEffect(
                symptoms: symptoms,
                severity: severity,
                recordedAt: Date(),
                cycleId: cycleId,
                bloodPressureSystolic: bloodPressureSystolic,
                bloodPressureDiastolic: bloodPressureDiastolic,
                moodRating: moodRating,
                libidoRating: libidoRating,
                acneSeverity: acneSeverity,
                notes: notes
            )
            
            sideEffects.insert(newSideEffect, at: 0)
            
        } catch {
            errorMessage = "Failed to log side effect: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Sample Data
    
    private var sampleCycles: [Cycle] {
        [
            Cycle(
                id: "1",
                userId: "current_user_id",
                name: "Test E + Tren Cycle",
                startDate: Date().addingTimeInterval(-30 * 24 * 3600), // 30 days ago
                endDate: nil,
                goals: ["Muscle Gain", "Strength", "Fat Loss"],
                compounds: [],
                notes: "First time running Tren. Starting conservative.",
                status: .active,
                createdAt: Date().addingTimeInterval(-30 * 24 * 3600),
                updatedAt: Date().addingTimeInterval(-30 * 24 * 3600)
            )
        ]
    }
    
    private var sampleInjections: [Injection] {
        [
            Injection(
                id: "1",
                userId: "current_user_id",
                cycleId: "1",
                compoundId: nil,
                compoundName: "Testosterone Enanthate",
                dosageMg: 250.0,
                injectionSite: .glute,
                injectionMethod: .im,
                needleGauge: 25,
                needleLengthMm: 25,
                notes: "Smooth injection, no issues",
                injectedAt: Date().addingTimeInterval(-2 * 24 * 3600), // 2 days ago
                createdAt: Date().addingTimeInterval(-2 * 24 * 3600)
            ),
            Injection(
                id: "2",
                userId: "current_user_id",
                cycleId: "1",
                compoundId: nil,
                compoundName: "Trenbolone Acetate",
                dosageMg: 200.0,
                injectionSite: .quad,
                injectionMethod: .im,
                needleGauge: 25,
                needleLengthMm: 25,
                notes: "Slight pip, but manageable",
                injectedAt: Date().addingTimeInterval(-1 * 24 * 3600), // 1 day ago
                createdAt: Date().addingTimeInterval(-1 * 24 * 3600)
            )
        ]
    }
    
    private var sampleSideEffects: [SideEffect] {
        [
            SideEffect(
                id: "1",
                userId: "current_user_id",
                cycleId: "1",
                symptoms: ["Acne", "Increased sweating"],
                severity: 3,
                bloodPressureSystolic: 140,
                bloodPressureDiastolic: 85,
                moodRating: 8,
                libidoRating: 9,
                acneSeverity: 4,
                notes: "Acne mostly on back and shoulders. Mood is great!",
                recordedAt: Date().addingTimeInterval(-1 * 24 * 3600), // 1 day ago
                createdAt: Date().addingTimeInterval(-1 * 24 * 3600)
            )
        ]
    }
    
    private var sampleCompounds: [Compound] {
        [
            Compound(
                id: "1",
                name: "Testosterone Enanthate",
                category: .testosterone,
                halfLifeHours: 168, // 7 days
                description: "Long-acting testosterone ester",
                isVerified: true,
                createdAt: Date()
            ),
            Compound(
                id: "2",
                name: "Trenbolone Acetate",
                category: .anabolic,
                halfLifeHours: 72, // 3 days
                description: "Potent anabolic steroid",
                isVerified: true,
                createdAt: Date()
            ),
            Compound(
                id: "3",
                name: "Nandrolone Decanoate",
                category: .anabolic,
                halfLifeHours: 336, // 14 days
                description: "Long-acting nandrolone ester",
                isVerified: true,
                createdAt: Date()
            ),
            Compound(
                id: "4",
                name: "Human Growth Hormone",
                category: .peptide,
                halfLifeHours: 4, // 4 hours
                description: "Recombinant human growth hormone",
                isVerified: true,
                createdAt: Date()
            )
        ]
    }
} 