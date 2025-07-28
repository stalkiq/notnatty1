//
//  HomeFeedView.swift
//  not natty
//
//  Created by Apple Id on 7/26/25.
//

import SwiftUI

struct HomeFeedView: View {
    @EnvironmentObject var postsManager: PostsManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedFilter: Post.PostType? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with refresh button
                HStack {
                    Spacer()
                    Button(action: {
                        Task {
                            await postsManager.fetchPosts()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Filter Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(title: "All", isSelected: selectedFilter == nil) {
                            selectedFilter = nil
                        }
                        
                        ForEach(Post.PostType.allCases, id: \.self) { postType in
                            FilterChip(
                                title: postType.displayName,
                                isSelected: selectedFilter == postType,
                                icon: postType.icon,
                                color: postType.color
                            ) {
                                selectedFilter = postType
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                .background(themeManager.backgroundColor)
                
                // Posts List
                if postsManager.isLoading {
                    Spacer()
                    ProgressView("Loading posts...")
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredPosts) { post in
                                PostCard(post: post)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        await postsManager.fetchPosts()
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            await postsManager.fetchPosts()
        }
    }
    
    private var filteredPosts: [Post] {
        if let filter = selectedFilter {
            return postsManager.posts.filter { $0.postType == filter }
        } else {
            return postsManager.posts
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var icon: String? = nil
    var color: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.orange : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
    }
}

struct PostCard: View {
    let post: Post
    @EnvironmentObject var postsManager: PostsManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showComments = false
    @State private var showUserProfile = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                // User Avatar
                Button(action: {
                    showUserProfile = true
                }) {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(post.user?.fullName ?? "User")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        if let verificationStatus = post.user?.verificationStatus {
                            Image(systemName: verificationStatus.icon)
                                .font(.caption)
                                .foregroundColor(verificationStatus == .verified ? .blue : .gray)
                        }
                    }
                    
                    HStack {
                        Text("@\(post.user?.username ?? "username")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(timeAgoString(from: post.createdAt))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: post.privacyLevel.icon)
                                .font(.caption)
                            Text(post.privacyLevel.displayName)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Post Type Badge
                HStack(spacing: 4) {
                    Image(systemName: post.postType.icon)
                        .font(.caption)
                    Text(post.postType.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(post.postType.color).opacity(0.2))
                .foregroundColor(Color(post.postType.color))
                .cornerRadius(8)
            }
            
            // Content
            Text(post.content)
                .font(.body)
                .multilineTextAlignment(.leading)
            
            // Compound Tags
            if !post.compoundTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(post.compoundTags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(12)
                        }
                    }
                }
            }
            
            // Media (placeholder for future implementation)
            if !post.mediaURLs.isEmpty {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                    )
            }
            
            // Engagement Metrics
            HStack {
                // Likes
                Button(action: {
                    Task {
                        await postsManager.likePost(post)
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(post.isLiked ? .red : .primary)
                        Text("\(post.engagementMetrics.likes)")
                            .font(.caption)
                    }
                }
                
                // Comments
                Button(action: {
                    showComments = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                        Text("\(post.engagementMetrics.comments)")
                            .font(.caption)
                    }
                }
                
                // Reposts
                Button(action: {
                    // TODO: Implement repost functionality
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.2.squarepath")
                        Text("\(post.engagementMetrics.reposts)")
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                // Share
                Button(action: {
                    // TODO: Implement share functionality
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            .foregroundColor(.primary)
            .font(.caption)
        }
        .padding()
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(16)
        .shadow(color: themeManager.shadowColor, radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showComments) {
            CommentsView(post: post)
        }
        .sheet(isPresented: $showUserProfile) {
            UserProfileView(user: post.user ?? User(
                id: post.userId,
                email: "",
                username: "unknown",
                fullName: nil,
                avatarURL: nil,
                bio: nil,
                heightCm: nil,
                weightKg: nil,
                dateOfBirth: nil,
                verificationStatus: .unverified,
                emailVerified: false,
                profileData: [:],
                settings: User.UserSettings(
                    privacy: .init(profileVisibility: "public", cycleVisibility: "followers", postVisibility: "public"),
                    notifications: .init(newFollowers: true, likes: true, comments: true, cycleReminders: true),
                    units: .init(weight: "kg", dosage: "mg", height: "cm")
                ),
                isActive: true,
                createdAt: Date(),
                updatedAt: Date()
            ))
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 60 {
            return "now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h"
        } else if interval < 2592000 {
            let days = Int(interval / 86400)
            return "\(days)d"
        } else {
            let months = Int(interval / 2592000)
            return "\(months)mo"
        }
    }
}

// Comments system implementation
struct CommentsView: View {
    let post: Post
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var postsManager: PostsManager
    @State private var newComment = ""
    @State private var comments: [Comment] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Comments List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if comments.isEmpty {
                            EmptyCommentsView()
                        } else {
                            ForEach(comments) { comment in
                                CommentRow(comment: comment)
                            }
                        }
                    }
                    .padding()
                }
                
                // Comment Input
                CommentInputView(
                    comment: $newComment,
                    onPost: {
                        postComment()
                    }
                )
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadComments()
            }
        }
    }
    
    private func loadComments() {
        Task {
            do {
                comments = try await APIService.shared.getComments(postId: post.id)
            } catch {
                print("Failed to load comments: \(error)")
                // Fallback to empty array if API fails
                comments = []
            }
        }
    }
    
    private func postComment() {
        guard !newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let commentContent = newComment
        newComment = "" // Clear input immediately for better UX
        
        Task {
            do {
                let newComment = try await APIService.shared.addComment(postId: post.id, content: commentContent)
                comments.insert(newComment, at: 0)
            } catch {
                print("Failed to post comment: \(error)")
                // Restore the comment text if posting failed
                newComment = commentContent
            }
        }
    }
    
    private func postComment() {
        guard !newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let comment = Comment(
            id: UUID().uuidString,
            userId: "current_user",
            postId: post.id,
            parentCommentId: nil,
            content: newComment,
            mediaURL: nil,
            isDeleted: false,
            createdAt: Date(),
            updatedAt: Date(),
            user:             User(
                id: "current_user",
                email: "you@example.com",
                username: "You",
                fullName: "You",
                avatarURL: nil,
                bio: nil,
                heightCm: nil,
                weightKg: nil,
                dateOfBirth: nil,
                verificationStatus: .unverified,
                emailVerified: false,
                profileData: [:],
                settings: User.UserSettings(
                    privacy: .init(profileVisibility: "public", cycleVisibility: "followers", postVisibility: "public"),
                    notifications: .init(newFollowers: true, likes: true, comments: true, cycleReminders: true),
                    units: .init(weight: "kg", dosage: "mg", height: "cm")
                ),
                isActive: true,
                createdAt: Date(),
                updatedAt: Date()
            )
        )
        
        comments.insert(comment, at: 0)
        newComment = ""
    }
}

// Using the Comment struct from Post.swift

struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(comment.user?.fullName ?? comment.user?.username ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(timeAgoString(from: comment.createdAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(comment.content)
                .font(.body)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 60 {
            return "now"
        } else if interval < 3600 {
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

struct EmptyCommentsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("No Comments Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Be the first to comment on this post!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct CommentInputView: View {
    @Binding var comment: String
    let onPost: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Add a comment...", text: $comment, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(1...3)
            
            Button(action: onPost) {
                Text("Post")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .cornerRadius(8)
            }
            .disabled(comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.systemGray4)),
            alignment: .top
        )
    }
}

struct UserProfileView: View {
    let user: User
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Profile for \(user.fullName ?? user.username)")
                    .font(.title)
                Text("Coming soon...")
                    .foregroundColor(.secondary)
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
}

#Preview {
    HomeFeedView()
        .environmentObject(PostsManager())
        .environmentObject(ThemeManager())
} 