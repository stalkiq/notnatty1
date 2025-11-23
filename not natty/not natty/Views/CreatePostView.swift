//
//  CreatePostView.swift
//  Not Natty
//
//  Created by Apple Id on 7/26/25.
//  Copyright © 2025 Not Natty. All rights reserved.
//

/**
 * Create Post View
 * 
 * Provides a comprehensive interface for creating new posts with support for:
 * - Multiple post types (general, progress, injection, cycle)
 * - Privacy level selection (public, followers, private)
 * - Compound tagging for steroid-related content
 * - Media upload capabilities
 * - Character limit validation
 */

import SwiftUI
import PhotosUI

struct CreatePostView: View {
    @EnvironmentObject var postsManager: PostsManager
    @Environment(\.dismiss) var dismiss
    
    @State private var content = ""
    @State private var selectedPostType: Post.PostType = .general
    @State private var selectedPrivacyLevel: Post.PrivacyLevel = .private
    @State private var selectedCompounds: [String] = []
    @State private var showCompoundSelector = false
    @State private var showImagePicker = false
    @State private var selectedImages: [UIImage] = []
    @State private var isPosting = false
    @State private var tempSelectedCompound: String = ""
    
    private let maxContentLength = 500
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                CreatePostHeader(
                    selectedPostType: $selectedPostType,
                    selectedPrivacyLevel: $selectedPrivacyLevel
                )
                
                // Content Area
                ScrollView {
                    VStack(spacing: 16) {
                        // Text Input
                        CreatePostTextInput(content: $content, maxContentLength: maxContentLength)
                        
                        // Supplement Tags
                        CreatePostCompoundSection(
                            compoundTags: $selectedCompounds,
                            showCompoundSelector: $showCompoundSelector
                        )
                        
                        // Media Section
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Media")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Button("Add Photo") {
                                    showImagePicker = true
                                }
                                .font(.caption)
                                .foregroundColor(.orange)
                            }
                            
                            if selectedImages.isEmpty {
                                Text("No media selected")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 8)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 80, height: 80)
                                                .clipped()
                                                .cornerRadius(8)
                                                .overlay(
                                                    Button(action: {
                                                        selectedImages.remove(at: index)
                                                    }) {
                                                        Image(systemName: "xmark.circle.fill")
                                                            .foregroundColor(.white)
                                                            .background(Color.black.opacity(0.5))
                                                            .clipShape(Circle())
                                                    }
                                                    .padding(4),
                                                    alignment: .topTrailing
                                                )
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        // Post Preview
                        if !content.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Preview")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                CreatePostPreviewCard(
                                    content: content,
                                    postType: selectedPostType,
                                    privacyLevel: selectedPrivacyLevel,
                                    compoundTags: selectedCompounds
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        Task {
                            await createPost()
                        }
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                    .disabled(!canPost)
                }
            }
        }
        .sheet(isPresented: $showCompoundSelector) {
            CompoundSelectorView(selectedCompound: $tempSelectedCompound, selectedCompounds: $selectedCompounds)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImages: $selectedImages)
        }
        .onChange(of: tempSelectedCompound) { oldValue, newValue in
            if !newValue.isEmpty {
                if !selectedCompounds.contains(newValue) { selectedCompounds.append(newValue) }
                tempSelectedCompound = ""
            }
        }
        .overlay(
            Group {
                if isPosting {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        
                        Text("Creating post...")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
            }
        )
    }
    
    private var canPost: Bool {
        !content.isEmpty && 
        content.count <= maxContentLength && 
        !isPosting
    }
    
    private func createPost() async {
        isPosting = true
        
        // Save selected images to temporary files and pass file URLs so they render locally
        let mediaURLs: [String] = selectedImages.compactMap { image in
            guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("post_\(UUID().uuidString).jpg")
            do { try data.write(to: url); return url.absoluteString } catch { return nil }
        }
        
        await postsManager.createPost(
            content: content,
            postType: selectedPostType,
            privacyLevel: .private,
            compoundTags: selectedCompounds,
            mediaURLs: mediaURLs
        )
        
        isPosting = false
        dismiss()
    }
}

// MARK: - Helper Views

struct CreatePostHeader: View {
    @Binding var selectedPostType: Post.PostType
    @Binding var selectedPrivacyLevel: Post.PrivacyLevel
    
    var body: some View {
        VStack(spacing: 16) {
            // Post Type Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Post.PostType.allCases, id: \.self) { postType in
                        PostTypeButton(
                            postType: postType,
                            isSelected: selectedPostType == postType
                        ) {
                            selectedPostType = postType
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Privacy Level Selector removed for personal mode
        }
        .padding(.vertical)
        .background(Color(.systemGray6))
    }
}

struct CreatePostTextInput: View {
    @Binding var content: String
    let maxContentLength: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextEditor(text: $content)
                .frame(minHeight: 120)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            
            HStack {
                Text("\(content.count)/\(maxContentLength)")
                    .font(.caption)
                    .foregroundColor(content.count > maxContentLength ? .red : .secondary)
                
                Spacer()
                
                if content.count > maxContentLength {
                    Text("Character limit exceeded")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
    }
}

struct CreatePostCompoundSection: View {
    @Binding var compoundTags: [String]
    @Binding var showCompoundSelector: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Compounds")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button("Add") {
                    showCompoundSelector = true
                }
                .font(.caption)
                .foregroundColor(.orange)
            }
            
            if compoundTags.isEmpty {
                Text("No compounds selected")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(compoundTags, id: \.self) { tag in
                            CompoundTag(compound: tag) {
                                compoundTags.removeAll { $0 == tag }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct PostTypeButton: View {
    let postType: Post.PostType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: postType.icon)
                    .font(.title2)
                
                Text(postType.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(width: 60, height: 60)
            .background(isSelected ? postType.tintColor : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
    }
}

// Using CompoundTag from CycleLogView.swift

struct CreatePostPreviewCard: View {
    let content: String
    let postType: Post.PostType
    let privacyLevel: Post.PrivacyLevel
    let compoundTags: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("You")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Text("now")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: privacyLevel.icon)
                                .font(.caption)
                            Text(privacyLevel.displayName)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Post Type Badge
                HStack(spacing: 4) {
                    Image(systemName: postType.icon)
                        .font(.caption)
                    Text(postType.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(postType.tintColor.opacity(0.2))
                .foregroundColor(postType.tintColor)
                .cornerRadius(8)
            }
            
            // Content
            Text(content)
                .font(.body)
                .multilineTextAlignment(.leading)
            
            // Compound Tags
            if !compoundTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(compoundTags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// CompoundSelectorView is defined in CycleLogView.swift

struct CompoundRow: View {
    let compound: String
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                Text(compound)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.orange)
                }
            }
        }
    }
}

// SearchBar is defined in VerifiedProfilesView.swift

struct ImagePicker: View {
    @Binding var selectedImages: [UIImage]
    @Environment(\.dismiss) var dismiss
    @State private var showLibraryPicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select Images")
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
                        showLibraryPicker = true
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
            .navigationTitle("Add Images")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showLibraryPicker) {
            PhotoPicker(selectedImages: $selectedImages)
        }
    }
}

// MARK: - UIKit Photo Picker Wrapper
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 5
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        init(_ parent: PhotoPicker) { self.parent = parent }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            for item in results {
                if item.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    item.itemProvider.loadObject(ofClass: UIImage.self) { obj, _ in
                        if let image = obj as? UIImage {
                            DispatchQueue.main.async { self.parent.selectedImages.append(image) }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CreatePostView()
        .environmentObject(PostsManager())
} 