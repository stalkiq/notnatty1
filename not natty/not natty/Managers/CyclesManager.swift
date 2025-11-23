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
    
    private var authManager: (any ObservableObject)?
    
    func setAuthManager(_ authManager: any ObservableObject) {
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
            // Dev/offline fallback so UI has content only if empty
            if cycles.isEmpty { cycles = sampleCycles }
            if injections.isEmpty { injections = sampleInjections }
            if sideEffects.isEmpty { sideEffects = sampleSideEffects }
            compounds = sampleCompounds
            errorMessage = "Loaded local data (offline)."
        }
        
        isLoading = false
    }
    
    func createCycle(name: String, startDate: Date, goals: [String], compounds: [CycleCompound], notes: String?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newCycle = try await APIService.shared.createCycle(
                name: name,
                startDate: startDate,
                goals: goals,
                compounds: compounds
            )
            
            cycles.append(newCycle)
            
        } catch {
            // Offline/local fallback: create a local cycle so UI updates immediately
            let localCycle = Cycle(
                id: UUID().uuidString,
                userId: "current_user_id",
                name: name,
                startDate: startDate,
                endDate: nil,
                goals: goals,
                compounds: compounds,
                notes: notes,
                status: .active,
                createdAt: Date(),
                updatedAt: Date()
            )
            cycles.append(localCycle)
            errorMessage = "Created local cycle (offline)."
        }
        
        isLoading = false
    }
    
    func logInjection(compoundName: String, dosageMg: Double, injectionSite: Injection.InjectionSite?, injectionMethod: Injection.InjectionMethod?, cycleId: String?, notes: String?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newInjection = try await APIService.shared.logInjection(
                cycleId: cycleId,
                compoundName: compoundName,
                dosageMg: dosageMg,
                injectionSite: injectionSite,
                injectionMethod: injectionMethod,
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
            let newSideEffect = try await APIService.shared.logSideEffect(
                cycleId: cycleId,
                symptoms: symptoms,
                severity: severity,
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
        []
    }
    
    private var sampleInjections: [Injection] {
        []
    }
    
    private var sampleSideEffects: [SideEffect] {
        []
    }
    
    private var sampleCompounds: [Compound] {
        [
            Compound(
                id: "1",
                name: "Creatine Monohydrate",
                category: .other,
                halfLifeHours: nil,
                description: "Supports ATP regeneration for strength and power",
                isVerified: true,
                createdAt: Date()
            ),
            Compound(
                id: "2",
                name: "Whey Protein",
                category: .other,
                halfLifeHours: nil,
                description: "Fast-digesting protein for recovery",
                isVerified: true,
                createdAt: Date()
            )
        ]
    }
} 