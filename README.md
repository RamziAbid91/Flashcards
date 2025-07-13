# 📚 Chinese Flashcards iOS App

A modern, intuitive iOS application for learning Chinese vocabulary through interactive flashcards and quizzes. Built with SwiftUI and designed for a seamless learning experience.

![iOS App](https://img.shields.io/badge/iOS-15.0+-blue.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0+-orange.svg)
![Swift](https://img.shields.io/badge/Swift-5.0+-red.svg)

## ✨ Features

### 🎯 Core Learning Features
- **Interactive Flashcards**: Browse through Chinese vocabulary with pinyin, English, and French translations
- **Smart Quiz Mode**: Test your knowledge with quizzes using only cards you've seen
- **Progress Tracking**: Monitor your learning progress with seen/unseen card tracking
- **Favorites System**: Mark and organize your favorite flashcards for quick access
- **Category-based Learning**: Organized content by difficulty and themes

### 🎨 User Experience
- **Modern UI/UX**: Clean, intuitive interface with smooth animations
- **Draggable Progress Bar**: Interactive navigation through flashcard decks
- **Haptic Feedback**: Tactile responses for better user engagement
- **Dark/Light Theme Support**: Comfortable viewing in any lighting condition
- **Offline Functionality**: Works completely offline, no internet required

### 🛠️ Administrative Features
- **Add Custom Cards**: Create and add your own flashcards through the admin panel
- **Data Persistence**: All progress and favorites are saved locally
- **Settings Management**: Customize app behavior and preferences

## 📱 Screenshots

<img width="1170" height="2532" alt="IMG_4184" src="https://github.com/user-attachments/assets/954fd4b6-8580-47d6-9830-1f49886f0c65" />
<img width="1170" height="2532" alt="IMG_4187" src="https://github.com/user-attachments/assets/b2af19f2-56a9-457b-bba5-f1915c9f96ec" />
<img width="1170" height="2532" alt="IMG_4185" src="https://github.com/user-attachments/assets/0a7a8bd6-266b-410f-b3fd-4a307f124653" />




## 🏗️ Architecture

### Project Structure
```
Flashcards_Chinese/
├── Models/
│   ├── Flashcard.swift          # Core flashcard data model
│   └── FlashcardDeck.swift     # Deck management and persistence
├── Views/
│   ├── MainViews/              # Main navigation and core views
│   ├── FlashcardViews/         # Flashcard display and interaction
│   ├── QuizViews/              # Quiz mode implementation
│   ├── FavoritesViews/         # Favorites management
│   ├── AdminViews/             # Administrative functions
│   ├── Components/             # Reusable UI components
│   └── SharedComponents/       # Shared UI elements
├── Utils/
│   ├── Theme.swift             # App theming and colors
│   └── HapticManager.swift     # Haptic feedback management
└── Assets.xcassets/           # App icons and images
```

### Key Components

#### Flashcard Model
- **Multi-language Support**: Chinese characters, pinyin, English, and French translations
- **Learning Metadata**: Difficulty levels, categories, and example sentences
- **Progress Tracking**: Seen/unseen status and favorite marking
- **Persistence**: Full Codable support for data saving

#### FlashcardDeck
- **Centralized Management**: Single source of truth for all flashcards
- **Category Organization**: Structured content by learning themes
- **Data Persistence**: Automatic saving of user progress and preferences

#### UI Architecture
- **SwiftUI Native**: Modern declarative UI framework
- **MVVM Pattern**: Clean separation of concerns
- **ObservableObject**: Reactive data binding throughout the app

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 15.0+ deployment target
- macOS 13.0+ (for development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/Flashcards_Chinese.git
   cd Flashcards_Chinese
   ```

2. **Open in Xcode**
   ```bash
   open Flashcards_Chinese.xcodeproj
   ```

3. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

### Configuration

The app is pre-configured with:
- Sample flashcards in multiple categories
- Default theme and settings
- Local data persistence

No additional setup required!

## 🎯 Usage

### Learning Flow
1. **Browse Flashcards**: Start with the "Cards" tab to explore vocabulary
2. **Mark Favorites**: Tap the heart icon to save important cards
3. **Take Quizzes**: Use the "Quiz" tab to test your knowledge
4. **Track Progress**: Monitor your learning in the "Favorites" tab
5. **Customize**: Add your own cards via the "Add Flashcard" tab

### Features in Detail

#### Flashcard Mode
- Swipe through cards with smooth animations
- Tap to reveal translations
- Drag progress bar for quick navigation
- Mark cards as favorites

#### Quiz Mode
- Intelligent card selection (seen cards only)
- Multiple choice questions
- Progress tracking
- Fallback to basic words if needed

#### Favorites Management
- View all favorited cards
- Quick access to important vocabulary
- Organized by categories

## 🎨 Design System

### Color Palette
- **Primary**: `#0277BD` (Blue)
- **Background**: `#FAF9F6` (Off-white)
- **Cards**: `#FFFFFF` (White)
- **Text**: `#263238` (Dark gray)
- **Accent**: `#66BB6A` (Green)

### Typography
- System fonts for optimal readability
- Hierarchical text sizing
- Proper contrast ratios for accessibility

## 🔧 Technical Details

### Dependencies
- **SwiftUI**: Native iOS UI framework
- **Foundation**: Core iOS functionality
- **UIKit**: Haptic feedback integration

### Data Management
- **UserDefaults**: Settings and preferences
- **Codable**: Data persistence
- **ObservableObject**: Reactive state management

### Performance
- **Lazy Loading**: Efficient memory usage
- **Smooth Animations**: 60fps interactions
- **Offline First**: No network dependencies

## 🐛 Known Issues

- None currently reported

## 🚧 Roadmap

### Planned Features
- [ ] Audio pronunciation support
- [ ] Spaced repetition algorithm
- [ ] Cloud sync capabilities
- [ ] Social features (sharing progress)
- [ ] Advanced analytics dashboard

### Improvements
- [ ] Enhanced accessibility features
- [ ] More language support
- [ ] Custom themes
- [ ] Export/import functionality

## 🤝 Contributing

We welcome contributions! Please feel free to submit issues and pull requests.

### Development Setup
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow Swift style guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistent indentation

## 📄 License

This project is licensed under the MIT License
## 👨‍💻 Author

**Ramzi Abid**
- GitHub: https://github.com/RamziAbid91/
- Email: ramziabid1991@gmail.com

## 🙏 Acknowledgments

- Chinese language learning community
- SwiftUI documentation and examples
- iOS development community

---

**Made with ❤️ for Chinese language learners**

*This app is designed to make learning Chinese vocabulary fun, efficient, and accessible to everyone.* 
