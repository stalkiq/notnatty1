//
//  ProfileView.swift
//  not natty
//
//  Created by Apple Id on 7/26/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var postsManager: PostsManager
    @EnvironmentObject var cyclesManager: CyclesManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTab = 0
    @State private var showSettings = false
    @State private var showEditProfile = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    Button("Settings") {
                        showSettings = true
                    }
                    .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Button("Edit") {
                        showEditProfile = true
                    }
                    .foregroundColor(.orange)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Profile Header
                ProfileHeaderView()
                
                // Tab Selector
                Picker("Profile Tabs", selection: $selectedTab) {
                    Text("Posts").tag(0)
                    Text("Cycles").tag(1)
                    Text("Stats").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    ProfilePostsTab()
                        .tag(0)
                    
                    ProfileCyclesTab()
                        .tag(1)
                    
                    ProfileStatsTab()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
        }
    }
}

struct ProfileHeaderView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var postsManager: PostsManager
    @EnvironmentObject var cyclesManager: CyclesManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar and Basic Info
            VStack(spacing: 12) {
                // Avatar
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                
                // Name and Verification Status
                VStack(spacing: 4) {
                    HStack {
                        Text(authManager.currentUser?.fullName ?? "User")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if let verificationStatus = authManager.currentUser?.verificationStatus {
                            Image(systemName: verificationStatus.icon)
                                .foregroundColor(verificationStatus == .verified ? .blue : .gray)
                        }
                    }
                    
                    Text("@\(authManager.currentUser?.username ?? "username")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Bio
                if let bio = authManager.currentUser?.bio, !bio.isEmpty {
                    Text(bio)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            
            // Stats
            HStack(spacing: 40) {
                StatItem(title: "Posts", value: "\(postsManager.posts.filter { $0.userId == authManager.currentUser?.id }.count)")
                StatItem(title: "Cycles", value: "\(cyclesManager.cycles.count)")
                StatItem(title: "Following", value: "0") // TODO: Implement following count
                StatItem(title: "Followers", value: "0") // TODO: Implement followers count
            }
            
            // Physical Stats (if available)
            if let height = authManager.currentUser?.heightCm,
               let weight = authManager.currentUser?.weightKg {
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("\(height)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("Height (cm)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(weight, specifier: "%.1f")")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("Weight (kg)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String?
    let color: Color?
    
    init(title: String, value: String, icon: String? = nil, color: Color? = nil) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        VStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color ?? .primary)
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ProfilePostsTab: View {
    @EnvironmentObject var postsManager: PostsManager
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                let userPosts = postsManager.posts.filter { $0.userId == authManager.currentUser?.id }
                
                if userPosts.isEmpty {
                    EmptyPostsView()
                } else {
                    ForEach(userPosts) { post in
                        PostCard(post: post)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

struct EmptyPostsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "text.bubble")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("No Posts Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Share your first post to start building your profile.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct ProfileCyclesTab: View {
    @EnvironmentObject var cyclesManager: CyclesManager
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if cyclesManager.cycles.isEmpty {
                    EmptyCyclesView()
                } else {
                    ForEach(cyclesManager.cycles) { cycle in
                        CycleCard(cycle: cycle)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

struct EmptyCyclesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("No Cycles Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Start tracking your first cycle to monitor progress.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct CycleCard: View {
    let cycle: Cycle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(cycle.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Started \(cycle.startDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: cycle.status)
            }
            
            // Goals
            if !cycle.goals.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Goals")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(cycle.goals, id: \.self) { goal in
                            Text(goal)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            if let notes = cycle.notes {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notes")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ProfileStatsTab: View {
    @EnvironmentObject var cyclesManager: CyclesManager
    @EnvironmentObject var postsManager: PostsManager
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Activity Stats
                ActivityStatsCard()
                
                // Cycle Stats
                CycleStatsCard()
                
                // Health Metrics
                HealthMetricsCard()
            }
            .padding()
        }
    }
}

struct ActivityStatsCard: View {
    @EnvironmentObject var postsManager: PostsManager
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity Stats")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                let userPosts = postsManager.posts.filter { $0.userId == authManager.currentUser?.id }
                
                StatItem(
                    title: "Total Posts",
                    value: "\(userPosts.count)",
                    icon: "text.bubble",
                    color: .blue
                )
                
                StatItem(
                    title: "Total Likes",
                    value: "\(userPosts.reduce(0) { $0 + $1.engagementMetrics.likes })",
                    icon: "heart",
                    color: .red
                )
                
                StatItem(
                    title: "Total Comments",
                    value: "\(userPosts.reduce(0) { $0 + $1.engagementMetrics.comments })",
                    icon: "bubble.left",
                    color: .green
                )
                
                StatItem(
                    title: "Days Active",
                    value: "30", // TODO: Calculate actual days
                    icon: "calendar",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct CycleStatsCard: View {
    @EnvironmentObject var cyclesManager: CyclesManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cycle Stats")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                StatItem(
                    title: "Total Cycles",
                    value: "\(cyclesManager.cycles.count)",
                    icon: "chart.bar.doc.horizontal",
                    color: .orange
                )
                
                StatItem(
                    title: "Total Injections",
                    value: "\(cyclesManager.injections.count)",
                    icon: "syringe",
                    color: .red
                )
                
                StatItem(
                    title: "Side Effects",
                    value: "\(cyclesManager.sideEffects.count)",
                    icon: "exclamationmark.triangle",
                    color: .yellow
                )
                
                StatItem(
                    title: "Compounds Used",
                    value: "\(cyclesManager.compounds.count)",
                    icon: "pills",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct HealthMetricsCard: View {
    @EnvironmentObject var cyclesManager: CyclesManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Health Metrics")
                .font(.headline)
                .fontWeight(.bold)
            
            if cyclesManager.sideEffects.isEmpty {
                Text("No health metrics recorded yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                // TODO: Implement health metrics visualization
                Text("Health metrics visualization coming soon...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Placeholder views for settings and edit profile
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            List {
                Section("Appearance") {
                    HStack {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.purple)
                            .frame(width: 20)
                        
                        Text("Dark Mode")
                        
                        Spacer()
                        
                        Toggle("", isOn: $themeManager.isDarkMode)
                            .labelsHidden()
                    }
                }
                
                Section("Account") {
                    Button("Edit Profile") {
                        // TODO: Show edit profile
                    }
                    
                    Button("Privacy Settings") {
                        // TODO: Show privacy settings
                    }
                    
                    Button("Notification Preferences") {
                        // TODO: Show notification settings
                    }
                }
                
                Section("Data & Privacy") {
                    Button("Export Data") {
                        // TODO: Export user data
                    }
                    
                    Button("Delete Account") {
                        // TODO: Show delete account confirmation
                    }
                    .foregroundColor(.red)
                }
                
                Section("Support") {
                    Button("Help & FAQ") {
                        // TODO: Show help
                    }
                    
                    Button("Contact Support") {
                        // TODO: Show contact form
                    }
                    
                    Button("Terms of Service") {
                        // TODO: Show terms
                    }
                    
                    Button("Privacy Policy") {
                        // TODO: Show privacy policy
                    }
                }
                
                Section {
                    Button("Sign Out") {
                        authManager.signOut()
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
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
}

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    
    @State private var fullName: String = ""
    @State private var username: String = ""
    @State private var bio: String = ""
    @State private var heightCm: String = ""
    @State private var weightKg: String = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profile Photo") {
                    HStack {
                        Spacer()
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.orange)
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Basic Information") {
                    TextField("Full Name", text: $fullName)
                    TextField("Username", text: $username)
                    TextField("Bio", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Physical Stats") {
                    HStack {
                        TextField("Height", text: $heightCm)
                            .keyboardType(.numberPad)
                        Text("cm")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        TextField("Weight", text: $weightKg)
                            .keyboardType(.decimalPad)
                        Text("kg")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Privacy") {
                    NavigationLink("Profile Visibility") {
                        PrivacySettingsView()
                    }
                    
                    NavigationLink("Cycle Visibility") {
                        PrivacySettingsView()
                    }
                    
                    NavigationLink("Post Visibility") {
                        PrivacySettingsView()
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadCurrentProfile()
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePickerView(selectedImage: $selectedImage)
            }
        }
    }
    
    private func loadCurrentProfile() {
        guard let user = authManager.currentUser else { return }
        fullName = user.fullName ?? ""
        username = user.username
        bio = user.bio ?? ""
        heightCm = user.heightCm?.description ?? ""
        weightKg = user.weightKg?.description ?? ""
    }
    
    private func saveProfile() {
        // TODO: Implement actual profile saving
        // For now, just dismiss
        dismiss()
    }
}

struct PrivacySettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedVisibility = "public"
    
    let visibilityOptions = [
        ("public", "Public", "globe"),
        ("followers", "Followers Only", "person.2"),
        ("private", "Private", "lock")
    ]
    
    var body: some View {
        List {
            ForEach(visibilityOptions, id: \.0) { option in
                Button(action: {
                    selectedVisibility = option.0
                }) {
                    HStack {
                        Image(systemName: option.2)
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        
                        Text(option.1)
                        
                        Spacer()
                        
                        if selectedVisibility == option.0 {
                            Image(systemName: "checkmark")
                                .foregroundColor(.orange)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
        }
        .navigationTitle("Privacy Settings")
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

struct ImagePickerView: View {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select Profile Photo")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(spacing: 16) {
                    Button(action: {
                        // TODO: Implement camera functionality
                    }) {
                        HStack {
                            Image(systemName: "camera")
                                .font(.title2)
                            Text("Take Photo")
                                .font(.body)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        // TODO: Implement photo library functionality
                    }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title2)
                            Text("Choose from Library")
                                .font(.body)
                        }
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Profile Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
        .environmentObject(PostsManager())
        .environmentObject(CyclesManager())
} 