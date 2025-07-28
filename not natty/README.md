# Not Natty - iOS App

<div align="center">
  <img src="https://img.shields.io/badge/iOS-15.0+-blue.svg" alt="iOS Version">
  <img src="https://img.shields.io/badge/Swift-5.9-orange.svg" alt="Swift Version">
  <img src="https://img.shields.io/badge/SwiftUI-4.0-green.svg" alt="SwiftUI Version">
  <img src="https://img.shields.io/badge/Xcode-15.0+-purple.svg" alt="Xcode Version">
</div>

A comprehensive iOS application for bodybuilding and steroid cycle tracking, built with SwiftUI and designed for the fitness community. Not Natty provides a social platform for sharing fitness progress, tracking steroid cycles, and connecting with like-minded individuals.

## 🚀 Features

### 📱 Social Media Feed
- **Post Creation**: Create posts with multiple types (general, progress, injection, cycle)
- **Privacy Controls**: Public, followers-only, or private posts
- **Media Support**: Upload and share images with posts
- **Engagement**: Like, comment, and repost functionality
- **Compound Tagging**: Tag posts with specific steroid compounds

### 💉 Cycle Tracking
- **Cycle Management**: Create and track steroid cycles
- **Injection Logging**: Record injection details (compound, dose, location, date)
- **Side Effect Monitoring**: Track and monitor side effects
- **Progress Analytics**: Visualize cycle progress and results
- **Compound Database**: Comprehensive database of steroid compounds

### 👤 User Management
- **Authentication**: Secure user registration and login
- **Profile Management**: Customizable user profiles
- **Privacy Settings**: Control who can see your content
- **Verified Profiles**: Special verification system for trusted users

### 📊 Analytics & Insights
- **Progress Tracking**: Monitor gains and changes over time
- **Cycle Analytics**: Analyze cycle effectiveness and side effects
- **Social Analytics**: Track engagement and reach of posts

## 🛠️ Technical Stack

- **Framework**: SwiftUI 4.0
- **Language**: Swift 5.9
- **Platform**: iOS 15.0+
- **Architecture**: MVVM with ObservableObject
- **State Management**: @StateObject and @EnvironmentObject
- **Backend**: Supabase (planned integration)

## 📋 Requirements

- **Xcode**: 15.0 or later
- **iOS**: 15.0 or later
- **macOS**: 12.0 or later (for development)
- **Swift**: 5.9 or later

## 🚀 Getting Started

### Prerequisites

1. **Install Xcode** from the Mac App Store
2. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/not-natty-ios.git
   cd not-natty-ios
   ```

### Installation

1. **Open the project** in Xcode:
   ```bash
   open "not natty.xcodeproj"
   ```

2. **Select a simulator** or connected device:
   - iPhone 16 or later recommended for testing
   - iOS 15.0+ required

3. **Build and run** the project:
   - Press `⌘ + R` or click the Run button
   - The app will launch in the simulator

### Demo Mode

The app currently runs in demo mode with sample data:
- **Login**: Use any email/password combination
- **Sample Data**: Pre-populated with example posts, cycles, and users
- **Full Functionality**: All features work with local data

## 📁 Project Structure

```
not natty/
├── not natty/
│   ├── Models/           # Data models
│   │   ├── Post.swift
│   │   ├── User.swift
│   │   └── Cycle.swift
│   ├── Managers/         # Business logic
│   │   ├── AuthManager.swift
│   │   ├── PostsManager.swift
│   │   └── CyclesManager.swift
│   ├── Views/            # UI components
│   │   ├── AuthenticationView.swift
│   │   ├── CreatePostView.swift
│   │   ├── HomeFeedView.swift
│   │   ├── ProfileView.swift
│   │   └── CycleLogView.swift
│   ├── MainTabView.swift # Main navigation
│   └── not_nattyApp.swift # App entry point
├── not nattyTests/       # Unit tests
├── not nattyUITests/     # UI tests
└── README.md
```

## 🧪 Testing

### Running Tests

1. **Unit Tests**:
   ```bash
   xcodebuild test -project "not natty.xcodeproj" -scheme "not natty" -destination "platform=iOS Simulator,name=iPhone 16"
   ```

2. **UI Tests**:
   - Open the project in Xcode
   - Select the UI test target
   - Press `⌘ + U` to run UI tests

### Manual Testing

1. **Authentication Flow**:
   - Test login with any credentials
   - Verify profile creation and management

2. **Post Creation**:
   - Create posts with different types
   - Test privacy settings
   - Verify compound tagging

3. **Cycle Tracking**:
   - Create new cycles
   - Log injections
   - Monitor side effects

## 🔧 Development

### Code Style

- **Swift Style Guide**: Follow Apple's Swift API Design Guidelines
- **Documentation**: All public APIs should be documented
- **Comments**: Use clear, concise comments for complex logic
- **Naming**: Use descriptive names for variables, functions, and classes

### Architecture

The app follows the **MVVM (Model-View-ViewModel)** pattern:

- **Models**: Data structures and business logic
- **Views**: SwiftUI views for UI presentation
- **Managers**: ObservableObject classes for state management

### State Management

- **@StateObject**: For owned objects
- **@EnvironmentObject**: For shared objects across views
- **@State**: For local view state
- **@Binding**: For two-way data binding

## 🚧 Roadmap

### Phase 1: Core Features ✅
- [x] Basic UI and navigation
- [x] Authentication system
- [x] Post creation and feed
- [x] Cycle tracking basics
- [x] Profile management

### Phase 2: Enhanced Features 🚧
- [ ] Supabase backend integration
- [ ] Real-time data synchronization
- [ ] Push notifications
- [ ] Image upload and storage
- [ ] Advanced analytics

### Phase 3: Advanced Features 📋
- [ ] Social features (followers, messaging)
- [ ] Advanced cycle planning
- [ ] Progress photo tracking
- [ ] Export and backup functionality
- [ ] Community features

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch**:
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Commit your changes**:
   ```bash
   git commit -m 'Add amazing feature'
   ```
4. **Push to the branch**:
   ```bash
   git push origin feature/amazing-feature
   ```
5. **Open a Pull Request**

### Contribution Guidelines

- Follow the existing code style
- Add tests for new functionality
- Update documentation as needed
- Ensure all tests pass before submitting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

**Important**: This app is designed for educational and tracking purposes only. The developers do not endorse or promote the use of performance-enhancing drugs. Users are responsible for understanding and complying with all applicable laws and regulations in their jurisdiction.

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/not-natty-ios/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/not-natty-ios/discussions)
- **Email**: support@notnatty.app

## 🙏 Acknowledgments

- **SwiftUI Community** for excellent documentation and examples
- **Apple Developer Team** for the amazing SwiftUI framework
- **Fitness Community** for inspiration and feedback

---

<div align="center">
  <p>Built with ❤️ for the fitness community</p>
  <p>Made with SwiftUI and Swift</p>
</div> 