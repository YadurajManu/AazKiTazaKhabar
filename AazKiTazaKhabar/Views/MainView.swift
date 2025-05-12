import SwiftUI
import SafariServices
import WebKit

struct MainView: View {
    @StateObject private var authService = AuthenticationService.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationView {
                NewsFeedView()
                    .navigationTitle("AazKiTazaKhabar")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Image(systemName: "newspaper")
                Text("News")
            }
            .tag(0)
            
            // Bookmarks Tab
            NavigationView {
                BookmarksView()
                    .navigationTitle("Bookmarks")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Image(systemName: "bookmark")
                Text("Bookmarks")
            }
            .tag(1)
            
            // Profile Tab
            NavigationView {
                ProfileView()
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
            .tag(2)
        }
        .accentColor(.white)
        .preferredColorScheme(.dark)
    }
}

struct NewsFeedView: View {
    @StateObject private var viewModel = NewsFeedViewModel()
    @State private var searchExpanded = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                // Search and Filter Bar
                HStack(spacing: 12) {
                    // Search Bar
                    SearchBarView(text: $viewModel.searchText, expanded: $searchExpanded)
                    
                    if !searchExpanded {
                        Button(action: {
                            // Show filter sheet or menu
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                
                // Filter Categories (only show when search is not expanded)
                if !searchExpanded {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // Region filters
                            ForEach(["All", "Indian", "Global"], id: \.self) { region in
                                FilterChip(label: region, selected: viewModel.selectedRegion == region) {
                                    viewModel.setRegion(region)
                                }
                            }
                            
                            // Divider between region and category filters
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 1, height: 24)
                                .padding(.horizontal, 4)
                            
                            // Category filters
                            ForEach(["All", "Politics", "Business", "Technology", "Entertainment", "Sports", "Health", "Science", "General"], id: \.self) { category in
                                FilterChip(label: category, selected: viewModel.selectedCategory == category) {
                                    viewModel.setCategory(category)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }
                
                Divider().background(Color.white.opacity(0.08))
                
                // Feed Content
                if viewModel.isLoading {
                    VStack(spacing: 20) {
                        ForEach(0..<3) { _ in
                            NewsCardView(article: .placeholder)
                                .shimmer()
                        }
                    }
                    .padding()
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)
                            .padding(.bottom, 8)
                        
                        Text(error)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            viewModel.fetchNews()
                        }) {
                            Text("Retry")
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }
                    .padding(32)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(viewModel.filteredArticles.isEmpty && viewModel.searchText.isEmpty ? viewModel.articles : viewModel.filteredArticles) { article in
                                NewsCardView(article: article)
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                                    .animation(.spring(response: 0.5, dampingFraction: 0.85), value: article.id)
                            }
                            
                            if viewModel.filteredArticles.isEmpty && !viewModel.searchText.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    
                                    Text("No results found for '\(viewModel.searchText)'")
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 50)
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        viewModel.refreshNews()
                    }
                }
            }
        }
        .onAppear {
            if viewModel.articles.isEmpty {
                viewModel.fetchNews()
            }
        }
    }
}

struct SearchBarView: View {
    @Binding var text: String
    @Binding var expanded: Bool
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(isFocused || !text.isEmpty ? .blue : .gray)
                .frame(width: 20, height: 20)
                .padding(.leading, 8)
            
            TextField("Search news...", text: $text)
                .padding(.vertical, 10)
                .foregroundColor(.white)
                .focused($isFocused)
                .onChange(of: isFocused) { newValue in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        expanded = newValue
                    }
                }
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .frame(width: 20, height: 20)
                }
                .padding(.trailing, 8)
                .transition(.opacity)
            }
        }
        .frame(height: 40)
        .background(Color.white.opacity(0.08))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isFocused ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 1.5)
        )
        .animation(.easeInOut(duration: 0.2), value: text)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

struct FilterChip: View {
    let label: String
    var selected: Bool
    var action: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 15, weight: selected ? .medium : .regular))
                .foregroundColor(selected ? .black : .white.opacity(0.9))
                .padding(.horizontal, 16)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(selected ? Color.white : Color.white.opacity(isHovering ? 0.08 : 0.04))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.white.opacity(0.2), .white.opacity(0.1)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                        .opacity(selected || isHovering ? 1 : 0.5)
                )
                .scaleEffect(selected ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selected)
        }
        .buttonStyle(PlainButtonStyle())
        .hoverEffect($isHovering)
    }
}

struct NewsCardView: View {
    let article: NewsArticle
    @StateObject private var authService = AuthenticationService.shared
    @State private var showWeb = false
    @State private var isSaved = false
    @State private var isBookmarkLoading = false
    @State private var showShareSheet = false
    @State private var isPressed = false
    @State private var showDetail = false
    @State private var fadeIn = false
    @Namespace private var animation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let imageUrl = article.imageUrl, let url = URL(string: imageUrl) {
                ZStack(alignment: .bottomTrailing) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                                .cornerRadius(16)
                                .shimmer()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                                .opacity(fadeIn ? 1 : 0)
                                .onAppear {
                                    withAnimation(.easeIn(duration: 0.3)) {
                                        fadeIn = true
                                    }
                                }
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                                .cornerRadius(16)
                        @unknown default:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                                .cornerRadius(16)
                        }
                    }
                    
                    // Quick action buttons
                    HStack(spacing: 12) {
                        Button(action: {
                            toggleBookmark()
                        }) {
                            Circle()
                                .fill(Color.black.opacity(0.7))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Group {
                                        if isBookmarkLoading {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(0.7)
                                        } else {
                                            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                                .font(.system(size: 16))
                                                .foregroundColor(isSaved ? .yellow : .white)
                                        }
                                    }
                                )
                        }
                        .scaleEffect(isSaved ? 1.1 : 1.0)
                        .disabled(isBookmarkLoading)
                        
                        Button(action: {
                            showShareSheet = true
                        }) {
                            Circle()
                                .fill(Color.black.opacity(0.7))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    .padding(.bottom, 12)
                    .padding(.trailing, 12)
                    .opacity(fadeIn ? 1 : 0)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Source and date with pill design
                HStack(spacing: 8) {
                    Text(article.source)
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.05))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    
                    Text(article.detectedCategory)
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.05))
                        .foregroundColor(categoryColor(article.detectedCategory))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                        )
                    
                    Spacer()
                    
                    Text(formattedDate(article.publishedAt))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                // Title with improved typography
                Text(article.title)
                    .font(.system(size: 18, weight: .bold))
                    .lineLimit(3)
                    .foregroundColor(.white)
                    .padding(.top, 4)
                
                // Description preview
                Text(article.description)
                    .font(.system(size: 14))
                    .lineLimit(showDetail ? 6 : 2)
                    .foregroundColor(.gray)
                    .padding(.top, 2)
                
                // Read more button with animation
                Button(action: {
                    if let url = URL(string: article.url) {
                        showWeb = true
                    }
                }) {
                    HStack {
                        Text("Read Full Article")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue)
                            .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                    )
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .opacity(isPressed ? 0.9 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
                .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.isPressed = pressing
                    }
                    if pressing {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    }
                }, perform: {})
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
            )
        }
        .padding(.horizontal, 2)
        .sheet(isPresented: $showWeb) {
            if let url = URL(string: article.url) {
                SafariView(url: url)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = URL(string: article.url) {
                ShareSheet(items: [article.title, url])
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showDetail.toggle()
            }
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        .onAppear {
            checkIfBookmarked()
        }
    }
    
    private func toggleBookmark() {
        isBookmarkLoading = true
        
        // Play haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        Task {
            do {
                if isSaved {
                    try await authService.removeBookmark(article)
                    
                    // Update UI state on main thread
                    await MainActor.run {
                        isSaved = false
                        isBookmarkLoading = false
                    }
                    
                    // Success feedback
                    let feedbackGenerator = UINotificationFeedbackGenerator()
                    feedbackGenerator.notificationOccurred(.success)
                } else {
                    try await authService.addBookmark(article)
                    
                    // Update UI state on main thread
                    await MainActor.run {
                        isSaved = true
                        isBookmarkLoading = false
                    }
                    
                    // Success feedback
                    let feedbackGenerator = UINotificationFeedbackGenerator()
                    feedbackGenerator.notificationOccurred(.success)
                }
            } catch {
                // Update UI state on main thread
                await MainActor.run {
                    isBookmarkLoading = false
                }
                
                // Error feedback
                let feedbackGenerator = UINotificationFeedbackGenerator()
                feedbackGenerator.notificationOccurred(.error)
            }
        }
    }
    
    private func checkIfBookmarked() {
        Task {
            do {
                let bookmarked = try await authService.isBookmarked(article)
                await MainActor.run {
                    isSaved = bookmarked
                }
            } catch {
                // Silently fail, defaulting to not bookmarked
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func categoryColor(_ category: String) -> Color {
        switch category {
        case "Politics":
            return .white.opacity(0.9)
        case "Sports":
            return .green.opacity(0.9)
        case "Technology":
            return .blue.opacity(0.9)
        case "Business":
            return .orange.opacity(0.9)
        case "Entertainment":
            return .purple.opacity(0.9)
        case "Health":
            return .red.opacity(0.9)
        case "Science":
            return .yellow.opacity(0.9)
        default:
            return .gray.opacity(0.9)
        }
    }
}

// Add ShareSheet for sharing functionality
struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Helper for favicon and API source
extension NewsArticle {
    var apiSource: String {
        if source.lowercased().contains("newsapi") { return "NewsAPI" }
        if source.lowercased().contains("gnews") { return "GNews" }
        if source.lowercased().contains("mediastack") { return "Mediastack" }
        return "Other"
    }
    var faviconURL: URL? {
        let host = URL(string: url)?.host ?? ""
        guard !host.isEmpty else { return nil }
        return URL(string: "https://www.google.com/s2/favicons?domain=")?.appendingPathComponent(host)
    }
}

// Shimmer effect for loading placeholder
extension View {
    func shimmer() -> some View {
        self
            .redacted(reason: .placeholder)
            .overlay(
                LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.3), Color.white.opacity(0.1)]),
                               startPoint: .leading, endPoint: .trailing)
                    .rotationEffect(.degrees(30))
                    .blendMode(.plusLighter)
                    .mask(self)
                    .animation(Animation.linear(duration: 1.2).repeatForever(autoreverses: false), value: UUID())
            )
    }
}

struct InAppWebView: UIViewRepresentable {
    let url: URL
    let onClose: () -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    static func dismantleUIView(_ uiView: WKWebView, coordinator: ()) {
        uiView.stopLoading()
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(onClose: onClose) }
    class Coordinator: NSObject {
        let onClose: () -> Void
        init(onClose: @escaping () -> Void) { self.onClose = onClose }
    }
}

struct InAppWebViewSheet: View {
    let url: URL
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            InAppWebView(url: url) {
                presentationMode.wrappedValue.dismiss()
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct BookmarksView: View {
    @StateObject private var authService = AuthenticationService.shared
    @State private var articles: [NewsArticle] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var showArticle = false
    @State private var selectedArticleURL: URL? = nil
    @State private var listRefreshTrigger = false  // Added to trigger refreshes
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            } else if articles.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "bookmark.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No Saved Articles")
                        .font(.title2)
                        .foregroundColor(.white)
                    Text("Bookmark articles to see them here")
                        .foregroundColor(.gray)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(articles) { article in
                            BookmarkCard(article: article, onRemove: {
                                removeBookmark(article)
                            })
                            .onTapGesture {
                                if let url = URL(string: article.url) {
                                    selectedArticleURL = url
                                    showArticle = true
                                }
                            }
                        }
                    }
                    .padding()
                }
                .refreshable {
                    await loadBookmarks()
                }
            }
            
            if let errorMessage = errorMessage {
                VStack {
                    Spacer()
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                        .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            Task {
                await loadBookmarks()
            }
        }
        .onChange(of: listRefreshTrigger) { _ in
            Task {
                await loadBookmarks()
            }
        }
        .sheet(isPresented: $showArticle) {
            if let url = selectedArticleURL {
                SafariView(url: url)
            }
        }
    }
    
    private func loadBookmarks() async {
        isLoading = true
        do {
            articles = try await authService.fetchBookmarks()
        } catch {
            errorMessage = "Failed to load bookmarks: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    private func removeBookmark(_ article: NewsArticle) {
        Task {
            do {
                try await authService.removeBookmark(article)
                
                // Update UI on main thread
                await MainActor.run {
                    // Remove from local list for immediate feedback
                    if let index = articles.firstIndex(where: { $0.id == article.id }) {
                        articles.remove(at: index)
                    }
                    
                    // Success haptic feedback
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                    // Refresh the list
                    listRefreshTrigger.toggle()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to remove bookmark: \(error.localizedDescription)"
                    
                    // Error feedback
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                }
            }
        }
    }
}

struct BookmarkCard: View {
    let article: NewsArticle
    let onRemove: () -> Void
    @State private var isRemoving = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                if let imageUrl = article.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                                .clipped()
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.white.opacity(0.5))
                                )
                        @unknown default:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                        }
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: "newspaper")
                                .foregroundColor(.white.opacity(0.5))
                        )
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(article.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(3)
                    
                    HStack {
                        Text(article.source)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text(article.detectedCategory)
                            .font(.caption)
                            .foregroundColor(categoryColor(article.detectedCategory))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(8)
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text(article.publishedAt, style: .date)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.leading, 8)
            }
            
            HStack {
                Button(action: {
                    if let url = URL(string: article.url) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Read Article")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(6)
                }
                
                Spacer()
                
                Button(action: {
                    isRemoving = true
                    onRemove()
                }) {
                    HStack {
                        if isRemoving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.7)
                        } else {
                            Image(systemName: "trash")
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 20, height: 20)
                    .padding(8)
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(6)
                }
                .disabled(isRemoving)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func categoryColor(_ category: String) -> Color {
        switch category {
        case "Politics":
            return .white.opacity(0.9)
        case "Sports":
            return .green.opacity(0.9)
        case "Technology":
            return .blue.opacity(0.9)
        case "Business":
            return .orange.opacity(0.9)
        case "Entertainment":
            return .purple.opacity(0.9)
        case "Health":
            return .red.opacity(0.9)
        case "Science":
            return .yellow.opacity(0.9)
        default:
            return .gray.opacity(0.9)
        }
    }
}

#Preview {
    MainView()
} 