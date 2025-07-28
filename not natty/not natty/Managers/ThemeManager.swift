//
//  ThemeManager.swift
//  not natty
//
//  Created by Apple Id on 7/26/25.
//

import SwiftUI
import Foundation

class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
    }
    
    // MARK: - Color Schemes
    var primaryColor: Color {
        return .orange
    }
    
    var backgroundColor: Color {
        return isDarkMode ? Color(.systemBackground) : Color(.systemBackground)
    }
    
    var secondaryBackgroundColor: Color {
        return isDarkMode ? Color(.secondarySystemBackground) : Color(.systemGray6)
    }
    
    var cardBackgroundColor: Color {
        return isDarkMode ? Color(.tertiarySystemBackground) : Color(.systemBackground)
    }
    
    var textColor: Color {
        return isDarkMode ? .white : .black
    }
    
    var secondaryTextColor: Color {
        return isDarkMode ? .gray : .secondary
    }
    
    var borderColor: Color {
        return isDarkMode ? Color(.separator) : Color(.systemGray4)
    }
    
    var shadowColor: Color {
        return isDarkMode ? .black.opacity(0.3) : .black.opacity(0.1)
    }
    
    // MARK: - Theme-specific colors
    var successColor: Color {
        return .green
    }
    
    var warningColor: Color {
        return .orange
    }
    
    var errorColor: Color {
        return .red
    }
    
    var infoColor: Color {
        return .blue
    }
    
    // MARK: - Toggle function
    func toggleTheme() {
        isDarkMode.toggle()
    }
} 