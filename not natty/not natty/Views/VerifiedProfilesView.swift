//
//  VerifiedProfilesView.swift
//  not natty
//
//  Created by Apple Id on 7/26/25.
//

import SwiftUI

struct VerifiedProfilesView: View {
    @State private var searchText = ""
    @State private var selectedCategory: VerifiedCategory = .all
    @State private var verifiedProfiles: [VerifiedProfile] = sampleVerifiedProfiles
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    Spacer()
                    Button("Request Verification") {
                        // TODO: Show verification request form
                    }
                    .font(.caption)
                    .foregroundColor(.orange)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Search Bar
                SearchBar(text: $searchText)
                    .padding()
                
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(VerifiedCategory.allCases, id: \.self) { category in
                            CategoryChip(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
                
                // Profiles List
                if verifiedProfiles.isEmpty {
                    EmptyStateView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredProfiles) { profile in
                                VerifiedProfileCard(profile: profile)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var filteredProfiles: [VerifiedProfile] {
        var profiles = verifiedProfiles
        
        // Filter by category
        if selectedCategory != .all {
            profiles = profiles.filter { $0.category == selectedCategory }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            profiles = profiles.filter { profile in
                profile.name.localizedCaseInsensitiveContains(searchText) ||
                profile.username.localizedCaseInsensitiveContains(searchText) ||
                profile.bio.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return profiles
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search verified profiles...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct CategoryChip: View {
    let category: VerifiedCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.orange : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

struct VerifiedProfileCard: View {
    let profile: VerifiedProfile
    @State private var showProfileDetail = false
    @State private var isFollowing = false
    
    var body: some View {
        Button(action: {
            showProfileDetail = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack(spacing: 12) {
                    // Avatar
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(profile.name)
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                        
                        Text("@\(profile.username)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(profile.category.displayName)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color(profile.category.color).opacity(0.2))
                            .foregroundColor(Color(profile.category.color))
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    // Follow Button
                    Button(action: {
                        isFollowing.toggle()
                    }) {
                        Text(isFollowing ? "Following" : "Follow")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(isFollowing ? Color(.systemGray5) : Color.orange)
                            .foregroundColor(isFollowing ? .primary : .white)
                            .cornerRadius(16)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            
            // Bio
            if !profile.bio.isEmpty {
                Text(profile.bio)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            // Stats
            HStack(spacing: 24) {
                VerifiedStatItem(title: "Followers", value: formatNumber(profile.followers))
                VerifiedStatItem(title: "Following", value: formatNumber(profile.following))
                VerifiedStatItem(title: "Posts", value: formatNumber(profile.posts))
            }
            
            // Current Cycle Info
            if let currentCycle = profile.currentCycle {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Cycle")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(currentCycle.name)
                                .font(.caption)
                                .fontWeight(.medium)
                            
                            Text("Week \(currentCycle.currentWeek) of \(currentCycle.totalWeeks)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(currentCycle.compounds.count) compounds")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text("\(currentCycle.totalDosage, specifier: "%.0f")mg/week")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            
            // Recent Posts Preview
            if !profile.recentPosts.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Posts")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                                                    ForEach(profile.recentPosts, id: \.self) { post in
                            VerifiedPostPreviewCard(post: post)
                        }
                        }
                    }
                }
            }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showProfileDetail) {
            VerifiedProfileDetailView(profile: profile)
        }
    }
    
    private func formatNumber(_ number: Int) -> String {
        if number >= 1_000_000 {
            return String(format: "%.1fM", Double(number) / 1_000_000)
        } else if number >= 1_000 {
            return String(format: "%.1fK", Double(number) / 1_000)
        } else {
            return "\(number)"
        }
    }
}

struct VerifiedStatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct VerifiedPostPreviewCard: View {
    let post: PostPreview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(post.content)
                .font(.caption)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            HStack {
                Text(post.type.displayName)
                    .font(.caption2)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color(post.type.color).opacity(0.2))
                    .foregroundColor(Color(post.type.color))
                    .cornerRadius(4)
                
                Spacer()
                
                Text(timeAgoString(from: post.createdAt))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .frame(width: 120)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d"
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("No Verified Profiles")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Verified profiles will appear here once they're available.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Data Models
struct VerifiedProfile: Identifiable, Codable {
    let id: String
    let name: String
    let username: String
    let bio: String
    let category: VerifiedCategory
    let followers: Int
    let following: Int
    let posts: Int
    let currentCycle: CurrentCycle?
    let recentPosts: [PostPreview]
    let verificationDate: Date
}

enum VerifiedCategory: String, CaseIterable, Codable {
    case all = "all"
    case bodybuilder = "bodybuilder"
    case influencer = "influencer"
    case coach = "coach"
    case athlete = "athlete"
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .bodybuilder: return "Bodybuilder"
        case .influencer: return "Influencer"
        case .coach: return "Coach"
        case .athlete: return "Athlete"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return .primary
        case .bodybuilder: return .orange
        case .influencer: return .purple
        case .coach: return .blue
        case .athlete: return .green
        }
    }
}

struct CurrentCycle: Codable {
    let name: String
    let currentWeek: Int
    let totalWeeks: Int
    let compounds: [String]
    let totalDosage: Double
}

struct PostPreview: Hashable, Codable {
    let content: String
    let type: Post.PostType
    let createdAt: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(content)
        hasher.combine(type)
        hasher.combine(createdAt)
    }
    
    static func == (lhs: PostPreview, rhs: PostPreview) -> Bool {
        return lhs.content == rhs.content && lhs.type == rhs.type && lhs.createdAt == rhs.createdAt
    }
}

// Sample Data
private var sampleVerifiedProfiles: [VerifiedProfile] {
    [
        VerifiedProfile(
            id: "1",
            name: "Mike Johnson",
            username: "mike_johnson_fitness",
            bio: "Professional bodybuilder and fitness coach. 10+ years experience in the industry.",
            category: .bodybuilder,
            followers: 125000,
            following: 850,
            posts: 1247,
            currentCycle: CurrentCycle(
                name: "Competition Prep",
                currentWeek: 8,
                totalWeeks: 12,
                compounds: ["Testosterone", "Trenbolone", "Masteron"],
                totalDosage: 750
            ),
            recentPosts: [
                PostPreview(
                    content: "Week 8 progress update. Feeling amazing on this cycle!",
                    type: .progress,
                    createdAt: Date().addingTimeInterval(-3600)
                ),
                PostPreview(
                    content: "Just finished my Test E injection. 250mg going strong!",
                    type: .injection,
                    createdAt: Date().addingTimeInterval(-7200)
                )
            ],
            verificationDate: Date().addingTimeInterval(-365 * 24 * 3600)
        ),
        VerifiedProfile(
            id: "2",
            name: "Sarah Chen",
            username: "sarah_fitness_coach",
            bio: "Certified personal trainer and nutrition specialist. Helping people achieve their fitness goals.",
            category: .coach,
            followers: 89000,
            following: 1200,
            posts: 892,
            currentCycle: nil,
            recentPosts: [
                PostPreview(
                    content: "New meal prep guide available! Check out my latest nutrition tips.",
                    type: .meal,
                    createdAt: Date().addingTimeInterval(-1800)
                )
            ],
            verificationDate: Date().addingTimeInterval(-180 * 24 * 3600)
        ),
        VerifiedProfile(
            id: "3",
            name: "Alex Rodriguez",
            username: "alex_rod_fitness",
            bio: "Fitness influencer and content creator. Sharing my journey and knowledge.",
            category: .influencer,
            followers: 250000,
            following: 1500,
            posts: 2156,
            currentCycle: CurrentCycle(
                name: "Bulking Cycle",
                currentWeek: 4,
                totalWeeks: 16,
                compounds: ["Testosterone", "Deca", "Dianabol"],
                totalDosage: 1200
            ),
            recentPosts: [
                PostPreview(
                    content: "Dianabol is kicking in! Strength gains are insane.",
                    type: .workout,
                    createdAt: Date().addingTimeInterval(-5400)
                )
            ],
            verificationDate: Date().addingTimeInterval(-90 * 24 * 3600)
        )
    ]
}

// Comprehensive profile detail view
struct VerifiedProfileDetailView: View {
    let profile: VerifiedProfile
    @Environment(\.dismiss) var dismiss
    @State private var isFollowing = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack(spacing: 16) {
                        // Avatar and Basic Info
                        VStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.orange)
                            
                            VStack(spacing: 4) {
                                HStack {
                                    Text(profile.name)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.blue)
                                        .font(.title3)
                                }
                                
                                Text("@\(profile.username)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text(profile.category.displayName)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color(profile.category.color).opacity(0.2))
                                    .foregroundColor(Color(profile.category.color))
                                    .cornerRadius(12)
                            }
                        }
                        
                        // Follow Button
                        Button(action: {
                            isFollowing.toggle()
                        }) {
                            Text(isFollowing ? "Following" : "Follow")
                                .font(.headline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(isFollowing ? Color(.systemGray5) : Color.orange)
                                .foregroundColor(isFollowing ? .primary : .white)
                                .cornerRadius(25)
                        }
                        
                        // Bio
                        if !profile.bio.isEmpty {
                            Text(profile.bio)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Stats Section
                    HStack(spacing: 40) {
                        VStack(spacing: 4) {
                            Text(formatNumber(profile.followers))
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Followers")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 4) {
                            Text(formatNumber(profile.following))
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Following")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 4) {
                            Text(formatNumber(profile.posts))
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Posts")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical)
                    
                    // Current Cycle Section
                    if let currentCycle = profile.currentCycle {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .foregroundColor(.orange)
                                Text("Current Cycle")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(currentCycle.name)
                                            .font(.title3)
                                            .fontWeight(.bold)
                                        
                                        Text("Week \(currentCycle.currentWeek) of \(currentCycle.totalWeeks)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("\(currentCycle.compounds.count) compounds")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        Text("\(Int(currentCycle.totalDosage))mg/week")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                // Compounds List
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Compounds:")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                        ForEach(currentCycle.compounds, id: \.self) { compound in
                                            Text(compound)
                                                .font(.caption)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.orange.opacity(0.1))
                                                .foregroundColor(.orange)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    
                    // Recent Posts Section
                    if !profile.recentPosts.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundColor(.orange)
                                Text("Recent Posts")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            
                            LazyVStack(spacing: 12) {
                                ForEach(profile.recentPosts, id: \.self) { post in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(post.content)
                                            .font(.body)
                                            .lineLimit(nil)
                                        
                                        HStack {
                                            Text(post.type.displayName)
                                                .font(.caption)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color(post.type.color).opacity(0.2))
                                                .foregroundColor(Color(post.type.color))
                                                .cornerRadius(8)
                                            
                                            Spacer()
                                            
                                            Text(timeAgoString(from: post.createdAt))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                }
                            }
                        }
                    }
                    
                    // Verification Info
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "checkmark.shield")
                                .foregroundColor(.blue)
                            Text("Verified Profile")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                        }
                        
                        Text("Verified on \(verificationDateString)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var verificationDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: profile.verificationDate)
    }
    
    private func formatNumber(_ number: Int) -> String {
        if number >= 1_000_000 {
            return String(format: "%.1fM", Double(number) / 1_000_000)
        } else if number >= 1_000 {
            return String(format: "%.1fK", Double(number) / 1_000)
        } else {
            return "\(number)"
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}

#Preview {
    VerifiedProfilesView()
} 