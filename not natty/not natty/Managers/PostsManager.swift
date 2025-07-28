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
    
    private var authManager: AuthManager?
    
    func setAuthManager(_ authManager: AuthManager) {
        self.authManager = authManager
    }
    
    // MARK: - Post Management
    
    func fetchPosts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            posts = try await APIService.shared.getPosts()
        } catch {
            errorMessage = "Failed to load posts: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func createPost(content: String, postType: Post.PostType, privacyLevel: Post.PrivacyLevel, compoundTags: [String] = [], mediaURLs: [String] = []) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newPost = try await APIService.shared.createPost(
                content: content,
                postType: postType.rawValue,
                privacyLevel: privacyLevel.rawValue,
                compoundTags: compoundTags
            )
            
            posts.insert(newPost, at: 0)
            
        } catch {
            errorMessage = "Failed to create post: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func likePost(_ post: Post) async {
        do {
            let (liked, likesCount) = try await APIService.shared.likePost(postId: post.id)
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
        [
            Post(
                id: "1",
                userId: "user1",
                content: "Just finished my Test E injection. 250mg going strong! 💪",
                mediaURLs: [],
                compoundTags: ["Testosterone Enanthate"],
                privacyLevel: .public,
                postType: .injection,
                relatedInjectionId: nil,
                relatedCycleId: nil,
                engagementMetrics: Post.EngagementMetrics(likes: 15, comments: 3, reposts: 1),
                isDeleted: false,
                createdAt: Date().addingTimeInterval(-3600),
                updatedAt: Date().addingTimeInterval(-3600)
            ),
            Post(
                id: "2",
                userId: "user2",
                content: "Week 8 progress update. Gained 12lbs so far on this cycle. Feeling amazing!",
                mediaURLs: [],
                compoundTags: ["Testosterone", "Trenbolone"],
                privacyLevel: .public,
                postType: .progress,
                relatedInjectionId: nil,
                relatedCycleId: nil,
                engagementMetrics: Post.EngagementMetrics(likes: 42, comments: 8, reposts: 5),
                isDeleted: false,
                createdAt: Date().addingTimeInterval(-7200),
                updatedAt: Date().addingTimeInterval(-7200)
            ),
            Post(
                id: "3",
                userId: "user3",
                content: "Meal prep Sunday! 4000 calories of clean bulking food ready for the week.",
                mediaURLs: [],
                compoundTags: [],
                privacyLevel: .public,
                postType: .meal,
                relatedInjectionId: nil,
                relatedCycleId: nil,
                engagementMetrics: Post.EngagementMetrics(likes: 28, comments: 12, reposts: 3),
                isDeleted: false,
                createdAt: Date().addingTimeInterval(-10800),
                updatedAt: Date().addingTimeInterval(-10800)
            ),
            Post(
                id: "4",
                userId: "user4",
                content: "Experiencing some acne on my back. Anyone have tips for managing sides?",
                mediaURLs: [],
                compoundTags: ["Testosterone"],
                privacyLevel: .followers,
                postType: .sideEffect,
                relatedInjectionId: nil,
                relatedCycleId: nil,
                engagementMetrics: Post.EngagementMetrics(likes: 7, comments: 15, reposts: 0),
                isDeleted: false,
                createdAt: Date().addingTimeInterval(-14400),
                updatedAt: Date().addingTimeInterval(-14400)
            ),
            Post(
                id: "5",
                userId: "user5",
                content: "Remember: Always get bloodwork done before starting a cycle. Safety first!",
                mediaURLs: [],
                compoundTags: [],
                privacyLevel: .public,
                postType: .general,
                relatedInjectionId: nil,
                relatedCycleId: nil,
                engagementMetrics: Post.EngagementMetrics(likes: 67, comments: 22, reposts: 18),
                isDeleted: false,
                createdAt: Date().addingTimeInterval(-18000),
                updatedAt: Date().addingTimeInterval(-18000)
            )
        ]
    }
} 