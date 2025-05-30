# Aaz Ki Taza Khabar 🇮🇳 - Today's Fresh News

**Aaz Ki Taza Khabar** (आज की ताज़ा ख़बर - *Today's Fresh News*) is a sleek and modern iOS news aggregator app designed to bring you the latest headlines from India and around the world. It offers a personalized and streamlined news reading experience, cutting through the noise to deliver the news that matters to you.

Stay informed, stay ahead! 🚀

## ✨ Features

Aaz Ki Taza Khabar is packed with features to enhance your news consumption:

*   📰 **Multi-Source News Aggregation**: Get news from diverse sources like NewsAPI, Mediastack, and GNews, ensuring a wide perspective.
*   🇮🇳 **India-Focused & Global News**: Easily switch between Indian and Global news feeds.
*   🔍 **Advanced Search & Filtering**: Quickly find articles with a powerful search and filter by categories (Politics, Business, Technology, etc.).
*   🔖 **Bookmarking**: Save articles to read later.
*   🤖 **AI-Powered Insights (Optional)**:
    *   **Summaries**: Get quick AI-generated summaries of articles.
    *   **Sentiment Analysis**: Understand the sentiment (positive, negative, neutral) of news pieces at a glance.
    *   *(Note: AI features require an OpenAI API key and enabling the `useAI` flag in `NewsService.swift`)*
*   👤 **User Authentication**: Secure sign-up and login using Firebase.
*   👋 **Personalized Onboarding**: A smooth onboarding experience for new users.
*   🎨 **Sleek Dark Mode Interface**: Enjoy a visually stunning and comfortable reading experience in dark mode, built with SwiftUI.
*   🔄 **Pull-to-Refresh**: Keep your news feed updated with a simple pull.
*   🔗 **Share Articles**: Easily share interesting news with friends.
*   🖼️ **Image Prioritization**: Articles with images are prioritized for a richer visual feed.
*   ⏱️ **Relative Timestamps**: See how recently articles were published (e.g., "2 hours ago").
*   📱 **Responsive Design**: Adapts beautifully to different iPhone screen sizes.

**(placeholder for a GIF showcasing the main news feed and scrolling)**
**(placeholder for a GIF showcasing search and filtering)**
**(placeholder for a GIF showcasing bookmarking and AI features)**

## 📸 App Screenshots

Here's a glimpse of Aaz Ki Taza Khabar in action:

---
**(Placeholder: Screenshot of the Main News Feed - showing various news cards)**
*Caption: Main news feed with a variety of articles.*
---
**(Placeholder: Screenshot of an Article opened in the in-app browser or a detail view if available)**
*Caption: Reading an article.*
---
**(Placeholder: Screenshot of the Search/Filter interface)**
*Caption: Searching for specific news or applying filters.*
---
**(Placeholder: Screenshot of the Bookmarks screen)**
*Caption: Your saved articles for later reading.*
---
**(Placeholder: Screenshot of the Profile screen)**
*Caption: User profile section.*
---
**(Placeholder: Screenshot of the Onboarding screens)**
*Caption: Smooth onboarding for new users.*
---

*(Tip: Replace these placeholders with actual screenshots of your app. Use high-quality images.)*

## 🛠️ Technology Stack

Aaz Ki Taza Khabar is built using a modern set of technologies:

*   **UI Framework**: SwiftUI
*   **Language**: Swift
*   **Authentication**: Firebase Authentication
*   **News Sources**:
    *   NewsAPI
    *   Mediastack
    *   GNews
*   **AI Features**: OpenAI GPT-3.5-turbo (for summaries and sentiment analysis)
*   **Concurrency**: Swift Concurrency (`async/await`)
*   **Networking**: `URLSession`
*   **Data Handling**: JSON parsing (`Codable`)
*   **Package Management**: Swift Package Manager
*   **Version Control**: Git & GitHub
*   **Custom Fonts**: Space Grotesk

## 🚀 Getting Started

Follow these instructions to set up and run Aaz Ki Taza Khabar on your local machine.

### Prerequisites

*   macOS (latest version recommended)
*   Xcode (latest version recommended, available from the Mac App Store)
*   Git
*   A Firebase project (for authentication)
*   API Keys for:
    *   NewsAPI
    *   Mediastack
    *   GNews
    *   OpenAI (optional, for AI features)

### Installation Steps

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/your-username/AazKiTazaKhabar.git
    cd AazKiTazaKhabar
    ```
    *(Replace `your-username` with the actual GitHub username or organization)*

2.  **Open the Project in Xcode:**
    *   Locate the `AazKiTazaKhabar.xcodeproj` file in the cloned directory.
    *   Double-click to open it in Xcode. Xcode should automatically handle Swift Package Manager dependencies.

3.  **Configure Firebase:**
    *   Go to your [Firebase Console](https://console.firebase.google.com/) and create a new iOS project (or use an existing one).
    *   Download the `GoogleService-Info.plist` file for your Firebase project.
    *   In Xcode, drag and drop this `GoogleService-Info.plist` file into the `AazKiTazaKhabar/` sub-directory (alongside `Info.plist`). Ensure it's added to the `AazKiTazaKhabar` target.

4.  **Add API Keys:**
    *   **News Service API Keys:**
        *   Open `AazKiTazaKhabar/NewsService.swift`.
        *   Replace the placeholder API keys with your actual keys:
            ```swift
            private let newsApiKey = "YOUR_NEWSAPI_KEY" // Replace with your NewsAPI key
            private let mediastackKey = "YOUR_MEDIASTACK_KEY" // Replace with your Mediastack key
            private let gnewsKey = "YOUR_GNEWS_KEY" // Replace with your GNews key
            ```
    *   **OpenAI API Key (Optional):**
        *   If you want to use the AI features:
            *   Open `AazKiTazaKhabar/AIService.swift`.
            *   Replace the placeholder API key:
                ```swift
                private let apiKey = "YOUR_OPENAI_API_KEY" // Replace with your OpenAI API key
                ```
            *   Additionally, in `AazKiTazaKhabar/NewsService.swift`, change the `useAI` flag to `true`:
                ```swift
                private var useAI = true // Set to true to enable AI features
                ```

5.  **Build and Run:**
    *   Select your target device or simulator in Xcode.
    *   Click the "Run" button (or press `Cmd+R`).

You should now have Aaz Ki Taza Khabar running! 🎉

## 📂 Project Structure

The project is organized to maintain a clear separation of concerns:

```
AazKiTazaKhabar/
├── AazKiTazaKhabarApp.swift    # Main app entry point
├── AIService.swift             # Handles AI-powered features (summaries, sentiment)
├── AuthenticationService.swift # Manages user authentication via Firebase
├── ContentView.swift           # Initial view (can be refactored or removed if not central)
├── GoogleService-Info.plist    # Firebase configuration file (you need to add this)
├── Info.plist                  # App's main property list
├── NewsArticle.swift           # Data model for news articles
├── NewsService.swift           # Fetches and processes news from various APIs
├── Assets.xcassets/            # App icons, images, and colors
├── Fonts/                      # Custom fonts (e.g., SpaceGrotesk-VariableFont_wght.ttf)
├── Views/                      # SwiftUI views for different screens
│   ├── LoginView.swift         # User login screen
│   ├── MainView.swift          # Main tabbed view (News Feed, Bookmarks, Profile)
│   ├── NewsFeedViewModel.swift # ViewModel for the news feed
│   ├── OnboardingView.swift    # Screens for new user onboarding
│   └── ProfileView.swift       # User profile screen
├── AazKiTazaKhabar.xcodeproj/  # Xcode project file
├── Package.swift               # Swift Package Manager dependencies
└── README.md                   # This file!
```

## 🧠 AI-Powered Features

Aaz Ki Taza Khabar integrates optional AI capabilities to enhance your news reading experience. These features are powered by OpenAI's GPT-3.5-turbo model.

### Article Summarization

*   Get concise summaries (2-3 sentences) of news articles, capturing the key points.
*   This helps you quickly grasp the essence of an article before diving into the full text.

### Sentiment Analysis

*   Understand the underlying sentiment of a news piece.
*   The AI analyzes the article and responds with "positive," "negative," or "neutral."

### Enabling AI Features

1.  **API Key**: Ensure you have added your OpenAI API key in `AazKiTazaKhabar/AIService.swift`.
2.  **Toggle Flag**: In `AazKiTazaKhabar/NewsService.swift`, set the `useAI` variable to `true`:
    ```swift
    private var useAI = true // Default is false
    ```

*Disclaimer: AI-generated content can sometimes be inaccurate or biased. Always cross-reference with original sources for critical information.*

## 🤝 Contributing

Contributions are welcome! If you'd like to improve Aaz Ki Taza Khabar, please feel free to:

1.  **Fork** the repository.
2.  Create a new **branch** for your feature or bug fix (`git checkout -b feature/your-feature-name`).
3.  Make your **changes**.
4.  **Commit** your changes (`git commit -m 'Add some amazing feature'`).
5.  **Push** to the branch (`git push origin feature/your-feature-name`).
6.  Open a **Pull Request**.

Please ensure your code adheres to the existing style and that any new features are well-tested.
