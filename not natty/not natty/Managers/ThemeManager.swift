//
//  ThemeManager.swift
//  Not Natty
//
//  Created by Apple Id on 7/26/25.
//  Copyright © 2025 Not Natty. All rights reserved.
//

/**
 * Theme Manager
 * 
 * Manages app-wide theming, dark/light mode preferences,
 * and color schemes for the Not Natty app.
 */

import SwiftUI
import Foundation

@MainActor
class ThemeManager: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @AppStorage("accentColor") var accentColor: String = "orange"
    @AppStorage("useSystemTheme") var useSystemTheme: Bool = true
    
    // MARK: - Computed Properties
    
    var backgroundColor: Color {
        isDarkMode ? Color(.systemBackground) : Color(.systemBackground)
    }
    
    var cardBackgroundColor: Color {
        isDarkMode ? Color(.secondarySystemBackground) : Color(.systemBackground)
    }
    
    var shadowColor: Color {
        isDarkMode ? Color.black.opacity(0.3) : Color.black.opacity(0.1)
    }
    
    var textColor: Color {
        isDarkMode ? Color.white : Color.black
    }
    
    var secondaryTextColor: Color {
        isDarkMode ? Color(.systemGray) : Color(.systemGray2)
    }
    
    var borderColor: Color {
        isDarkMode ? Color(.systemGray4) : Color(.systemGray5)
    }
    
    var primaryAccentColor: Color {
        switch accentColor {
        case "orange": return .orange
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "red": return .red
        default: return .orange
        }
    }
    
    // MARK: - Theme Methods
    
    func toggleDarkMode() {
        isDarkMode.toggle()
    }
    
    func setDarkMode(_ enabled: Bool) {
        isDarkMode = enabled
    }
    
    func setAccentColor(_ color: String) {
        accentColor = color
    }
    
    func setSystemTheme(_ enabled: Bool) {
        useSystemTheme = enabled
        if enabled {
            // Use system setting
            isDarkMode = UIScreen.main.traitCollection.userInterfaceStyle == .dark
        }
    }
    
    // MARK: - Color Schemes
    
    static let availableAccentColors = [
        ("orange", "Orange", Color.orange),
        ("blue", "Blue", Color.blue),
        ("green", "Green", Color.green),
        ("purple", "Purple", Color.purple),
        ("red", "Red", Color.red)
    ]
    
    // MARK: - Custom Colors for PED Tracking
    
    var injectionColor: Color {
        return .orange
    }
    
    var progressColor: Color {
        return .green
    }
    
    var sideEffectColor: Color {
        return .red
    }
    
    var mealColor: Color {
        return .purple
    }
    
    var workoutColor: Color {
        return .blue
    }
    
    // MARK: - Compound Category Colors
    
    func colorForCompoundCategory(_ category: Compound.CompoundCategory) -> Color {
        switch category {
        case .testosterone:
            return .blue
        case .anabolic:
            return .red
        case .peptide:
            return .green
        case .sarm:
            return .purple
        case .other:
            return .gray
        }
    }
    
    // MARK: - Cycle Status Colors
    
    func colorForCycleStatus(_ status: Cycle.CycleStatus) -> Color {
        switch status {
        case .planned:
            return .blue
        case .active:
            return .green
        case .completed:
            return .gray
        case .cancelled:
            return .red
        }
    }
} 