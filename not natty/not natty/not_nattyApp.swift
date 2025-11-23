//
//  not_nattyApp.swift
//  Not Natty
//
//  Created by Apple Id on 7/26/25.
//  Copyright © 2025 Not Natty. All rights reserved.
//

/**
 * Not Natty - iOS App
 * 
 * A comprehensive iOS application for bodybuilding and steroid cycle tracking,
 * built with SwiftUI and designed for the fitness community.
 * 
 * Features:
 * - Social media feed for fitness content
 * - Cycle tracking and injection logging
 * - Progress monitoring and analytics
 * - User authentication and profiles
 * - Privacy controls and content management
 */

import SwiftUI

@main
struct not_nattyApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var postsManager = PostsManager()
    @StateObject private var cyclesManager = CyclesManager()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var supplementsManager = SupplementsManager()
    private let container = AppContainer.live()
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                MainTabView()
                    .environmentObject(authManager)
                    .environmentObject(postsManager)
                    .environmentObject(cyclesManager)
                    .environmentObject(themeManager)
                    .environmentObject(supplementsManager)
                    .environment(\.appContainer, container)
                    .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
                    .onAppear {
                        // Connect managers when the main view appears
                        postsManager.setAuthManager(authManager)
                        cyclesManager.setAuthManager(authManager)
                        supplementsManager.ensureCatalogLoaded()
                    }
            } else {
                AuthenticationView()
                    .environmentObject(authManager)
                    .environmentObject(themeManager)
                    .environmentObject(supplementsManager)
                    .environment(\.appContainer, container)
                    .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
                    .onAppear {
                        // Connect managers when the auth view appears
                        postsManager.setAuthManager(authManager)
                        cyclesManager.setAuthManager(authManager)
                        supplementsManager.ensureCatalogLoaded()
                    }
            }
        }
    }
}
