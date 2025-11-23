//
//  Post.swift
//  Not Natty
//
//  Created by Apple Id on 7/26/25.
//  Copyright © 2025 Not Natty. All rights reserved.
//

/**
 * Post Model
 * 
 * Represents a social media post in the Not Natty app.
 * Supports various post types including general updates, progress tracking,
 * injection logs, and cycle updates with privacy controls.
 */

import Foundation
import SwiftUI

struct Post: Identifiable, Codable {
    let id: String
    let userId: String
    let content: String
    let mediaURLs: [String]
    let compoundTags: [String]
    let privacyLevel: PrivacyLevel
    let postType: PostType
    let relatedInjectionId: String?
    let relatedCycleId: String?
    var engagementMetrics: EngagementMetrics
    let isDeleted: Bool
    let createdAt: Date
    let updatedAt: Date
    
    // Computed properties
    var user: User?
    var comments: [Comment] = []
    
    // Stored properties for UI state
    var isLiked: Bool = false
    
    // Mutating function to update like status
    mutating func toggleLike() {
        isLiked.toggle()
    }
    
    enum PrivacyLevel: String, Codable, CaseIterable {
        case `public` = "public"
        case `private` = "private"
        
        var displayName: String {
            switch self {
            case .public: return "Public"
            case .private: return "Private"
            }
        }
        
        var icon: String {
            switch self {
            case .public: return "globe"
            case .private: return "lock"
            }
        }
    }
    
    enum PostType: String, Codable, CaseIterable {
        case general = "general"
        case injection = "injection"
        case progress = "progress"
        case meal = "meal"
        case workout = "workout"
        case sideEffect = "side_effect"
        
        var displayName: String {
            switch self {
            case .general: return "General"
            case .injection: return "Supplement Dose"
            case .progress: return "Progress"
            case .meal: return "Meal"
            case .workout: return "Workout"
            case .sideEffect: return "Side Effect"
            }
        }
        
        var icon: String {
            switch self {
            case .general: return "text.bubble"
            case .injection: return "pills"
            case .progress: return "chart.line.uptrend.xyaxis"
            case .meal: return "fork.knife"
            case .workout: return "dumbbell"
            case .sideEffect: return "exclamationmark.triangle"
            }
        }
        
        var tintColor: Color {
            switch self {
            case .general: return .blue
            case .injection: return .orange
            case .progress: return .green
            case .meal: return .purple
            case .workout: return .red
            case .sideEffect: return .yellow
            }
        }
    }
    
    struct EngagementMetrics: Codable {
        var likes: Int
        var comments: Int
        var reposts: Int
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case content
        case mediaURLs = "media_urls"
        case compoundTags = "compound_tags"
        case privacyLevel = "privacy_level"
        case postType = "post_type"
        case relatedInjectionId = "related_injection_id"
        case relatedCycleId = "related_cycle_id"
        case engagementMetrics = "engagement_metrics"
        case isDeleted = "is_deleted"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Comment: Identifiable, Codable {
    let id: String
    let userId: String
    let postId: String
    let parentCommentId: String?
    let content: String
    let mediaURL: String?
    let isDeleted: Bool
    let createdAt: Date
    let updatedAt: Date
    
    var user: User?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case postId = "post_id"
        case parentCommentId = "parent_comment_id"
        case content
        case mediaURL = "media_url"
        case isDeleted = "is_deleted"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
} 