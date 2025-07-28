//
//  MainTabView.swift
//  not natty
//
//  Created by Apple Id on 7/26/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeFeedView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            CycleLogView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Cycle Log")
                }
                .tag(1)
            
            CreatePostView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Post")
                }
                .tag(2)
            
            VerifiedProfilesView()
                .tabItem {
                    Image(systemName: "checkmark.seal.fill")
                    Text("Verified")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(.orange)
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = themeManager.isDarkMode ? UIColor.systemBackground : UIColor.systemBackground
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthManager())
        .environmentObject(PostsManager())
        .environmentObject(CyclesManager())
        .environmentObject(ThemeManager())
} 