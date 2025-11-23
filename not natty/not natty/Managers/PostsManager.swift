//
//  PostsManager.swift
//  Not Natty
//
//  Created by Apple Id on 7/26/25.
//  Copyright © 2025 Not Natty. All rights reserved.
//

/**
 * Posts Manager
 * 
 * Manages all post-related operations including creation, deletion,
 * liking, and data persistence. Handles the social media feed
 * functionality of the Not Natty app.
 */

import Foundation
import SwiftUI

@MainActor
class PostsManager: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private weak var authManager: AuthManager?
    
    func setAuthManager(_ authManager: AuthManager) {
        self.authManager = authManager
    }
    
    // MARK: - Post Management
    
    func fetchPosts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let all = try await APIService.shared.getPosts()
            if let me = authManager?.currentUser?.id {
                posts = all.filter { $0.userId == me }
            } else {
                posts = all
            }
        } catch {
            // Offline/dev fallback so UI shows content
            posts = samplePosts
            errorMessage = "Loaded local sample posts (offline)."
        }
        
        isLoading = false
    }
    
    func createPost(content: String, postType: Post.PostType, privacyLevel: Post.PrivacyLevel, compoundTags: [String] = [], mediaURLs: [String] = []) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newPost = try await APIService.shared.createPost(
                content: content,
                mediaURLs: mediaURLs,
                compoundTags: compoundTags,
                privacyLevel: .private,
                postType: postType
            )
            posts.insert(newPost, at: 0)
        } catch {
            // Offline/local fallback: create a local post so UI updates immediately
            let newPost = Post(
                id: UUID().uuidString,
                userId: authManager?.currentUser?.id ?? "local-user",
                content: content,
                mediaURLs: mediaURLs,
                compoundTags: compoundTags,
                privacyLevel: .private,
                postType: postType,
                relatedInjectionId: nil,
                relatedCycleId: nil,
                engagementMetrics: Post.EngagementMetrics(likes: 0, comments: 0, reposts: 0),
                isDeleted: false,
                createdAt: Date(),
                updatedAt: Date()
            )
            posts.insert(newPost, at: 0)
        }
        
        isLoading = false
    }
    
    func likePost(_ post: Post) async {
        do {
            let (liked, likesCount) = try await APIService.shared.likePost(post)
            if let index = posts.firstIndex(where: { $0.id == post.id }) {
                posts[index].isLiked = liked
                posts[index].engagementMetrics.likes = likesCount
            }
        } catch {
            errorMessage = "Failed to like post: \(error.localizedDescription)"
        }
    }
    
    func deletePost(_ post: Post) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // TODO: Implement Supabase post deletion
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
            
            posts.removeAll { $0.id == post.id }
            
        } catch {
            errorMessage = "Failed to delete post: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Sample Data
    
    private var samplePosts: [Post] {
        []
    }
} 