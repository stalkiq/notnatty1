# 💪 Not Natty - iOS App

A comprehensive iOS application for bodybuilding and performance-enhancing drug (PED) cycle tracking, built with SwiftUI.

## 📱 Features

- **Social Media Feed**: Share and view posts about cycles, progress, and fitness
- **Cycle Tracking**: Log and monitor PED cycles with detailed analytics
- **Injection Logging**: Track injections with compound details and injection sites
- **Side Effect Monitoring**: Monitor health metrics and side effects
- **User Profiles**: Manage profiles with verification system
- **Privacy Controls**: Granular privacy settings for posts and cycles
- **Dark/Light Mode**: Full theme support with customizable colors

## 🏗️ Architecture

- **Framework**: SwiftUI with iOS 18.5+
- **State Management**: ObservableObject with @Published properties
- **Navigation**: TabView with modal presentations
- **Data Models**: Comprehensive models for users, posts, cycles, and injections
- **Mock Data**: Built-in mock data for development and testing

## 📁 Project Structure

```
not natty/
├── not natty/
│   ├── Models/              # Data models
│   │   ├── User.swift
│   │   ├── Post.swift
│   │   └── Cycle.swift
│   ├── Views/               # SwiftUI views
│   │   ├── HomeFeedView.swift
│   │   ├── CycleLogView.swift
│   │   ├── CreatePostView.swift
│   │   ├── ProfileView.swift
│   │   ├── VerifiedProfilesView.swift
│   │   ├── AuthenticationView.swift
│   │   └── ComplianceView.swift
│   ├── Managers/            # Business logic managers
│   │   ├── AuthManager.swift
│   │   ├── MockAuthManager.swift
│   │   ├── PostsManager.swift
│   │   ├── CyclesManager.swift
│   │   ├── ThemeManager.swift
│   │   ├── GeolocationManager.swift
│   │   └── ContentModerationManager.swift
│   ├── Services/            # API and external services
│   │   └── APIService.swift
│   ├── MainTabView.swift    # Main navigation
│   ├── not_nattyApp.swift   # App entry point
│   └── ContentView.swift    # Legacy view (can be removed)
├── not natty.xcodeproj/     # Xcode project
├── not nattyTests/          # Unit tests
└── not nattyUITests/        # UI tests
```

## 🚀 Getting Started

### Prerequisites

- Xcode 16.0 or later
- iOS 18.5+ deployment target
- macOS 14.0 or later

### Installation

1. Clone or download the project
2. Open `not natty.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run the project (⌘+R)

### Development Setup

The app uses mock data for development:

- **Demo User**: `demo@notnatty.com` / `password`
- **Verified User**: `verified@notnatty.com` / `password`

## 🎯 Core Features

### Authentication & Compliance
- Age verification (18+ required)
- Safety warnings and medical disclaimers
- Location permission for gym tracking
- Privacy controls and content moderation

### Social Features
- Post creation with media support
- Compound tagging system
- Privacy levels (Public, Followers, Private)
- Like, comment, and repost functionality
- User profiles with verification badges

### Cycle Tracking
- Create and manage PED cycles
- Log injections with detailed information
- Track side effects and health metrics
- Visual analytics and trend analysis
- Export functionality for data portability

### User Management
- Profile customization
- Privacy settings
- Verification system
- Follower/Following management

## 🔧 Technical Details

### State Management
- Uses SwiftUI's `@StateObject` and `@EnvironmentObject`
- Managers handle business logic and data operations
- Mock data for development without backend dependencies

### UI/UX
- Modern SwiftUI design with custom components
- Dark/Light mode support
- Accessibility features
- Responsive layout for different screen sizes

### Data Models
- Comprehensive models for all app features
- Codable support for data persistence
- Type-safe enums for status and categories

## 📋 Development Notes

### Mock Data
The app includes comprehensive mock data for testing:
- Sample users with different verification statuses
- Example posts with various content types
- Cycle data with injections and side effects
- Compound database with categories

### API Service
The `APIService` class provides a complete interface for backend integration:
- Authentication endpoints
- CRUD operations for all models
- Error handling and response parsing
- Ready for real backend implementation

### Content Moderation
Built-in content moderation features:
- Keyword filtering
- Medical advice detection
- User blocking and reporting
- Safety warnings and disclaimers

## 🛡️ Privacy & Safety

- Age verification required
- Medical disclaimers and safety warnings
- Content moderation and filtering
- Privacy controls for user data
- Location data protection

## 📄 License

This project is for educational and development purposes. Please ensure compliance with local laws and regulations regarding performance-enhancing drugs and medical advice.

## 🤝 Contributing

This is a local development project. For modifications:
1. Make changes in Xcode
2. Test with mock data
3. Ensure all features work correctly
4. Update documentation as needed

## 📞 Support

For development questions or issues:
- Check the code comments for implementation details
- Review the model structures for data relationships
- Test with the provided mock data

---

**Note**: This app is designed for educational purposes and cycle tracking. Always consult healthcare professionals before using performance-enhancing drugs. 