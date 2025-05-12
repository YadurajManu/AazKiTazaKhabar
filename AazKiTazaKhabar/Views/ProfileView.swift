import SwiftUI
import FirebaseAuth
import SafariServices

struct ProfileView: View {
    @StateObject private var authService = AuthenticationService.shared
    @State private var showSignOutAlert = false
    @State private var showEditProfile = false
    @State private var newDisplayName = ""
    @State private var newPhotoURL: URL? = nil
    @State private var isSaving = false
    @State private var saveError: String? = nil
    @State private var showChangePassword = false
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var isChangingPassword = false
    @State private var changePasswordError: String? = nil
    @State private var showDeleteAccount = false
    @State private var showUserPreferences = false
    @State private var notificationsEnabled = false
    @State private var darkModeEnabled = true
    @State private var selectedRegion = "India"
    @State private var appVersion = "1.0.0" // Replace with actual version in Info.plist
    @State private var isLoading = false
    @State private var isUpdatingPreferences = false
    @State private var isDeletingAccount = false
    @State private var errorMessage: String? = nil
    @State private var showBookmarks = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header Section with improved design
                    ZStack(alignment: .top) {
                        // Background gradient
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.7)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 150)
                            .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
                        
                        VStack(spacing: 10) {
                            // Profile Photo with animation
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 110, height: 110)
                                
                                if let photoURL = authService.user?.photoURL {
                                    AsyncImage(url: photoURL) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .transition(.opacity)
                                        case .failure:
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .foregroundColor(.white)
                                        @unknown default:
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(.white)
                                }
                                
                                // Edit profile button overlay
                                Button(action: {
                                    newDisplayName = authService.user?.displayName ?? ""
                                    newPhotoURL = authService.user?.photoURL
                                    showEditProfile = true
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.black.opacity(0.6))
                                            .frame(width: 32, height: 32)
                                        
                                        Image(systemName: "pencil")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .offset(x: 35, y: 35)
                            }
                            .padding(.top, 30)
                            
                            // Name with improved typography
                            Text(authService.user?.displayName ?? "No Name")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                            
                            // Email with subtle styling
                            Text(authService.user?.email ?? "No email")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.bottom, 12)
                        }
                        .padding(.top, 20)
                    }
                    .padding(.bottom, 20)
                    
                    // Stats section
                    HStack(spacing: 0) {
                        StatCard(value: "0", label: "Articles Read", icon: "book.fill", color: .blue)
                        StatCard(value: "0", label: "Bookmarks", icon: "bookmark.fill", color: .orange)
                        StatCard(value: "0", label: "Categories", icon: "folder.fill", color: .green)
                    }
                    .padding(.horizontal)
                    
                    // Account Options
                    ProfileSectionHeader(title: "Account Options")
                    
                    // View Bookmarks in Profile
                    Button(action: {
                        showBookmarks = true
                    }) {
                        HStack {
                            Image(systemName: "bookmark.fill")
                                .foregroundColor(.blue)
                            Text("Saved Articles")
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 16)
                    .sheet(isPresented: $showBookmarks) {
                        BookmarksProfileView()
                    }
                    
                    // User Preferences
                    Button(action: {
                        showUserPreferences = true
                    }) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.orange)
                            Text("App Preferences")
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 16)
                    .sheet(isPresented: $showUserPreferences) {
                        VStack(spacing: 20) {
                            Text("App Preferences").font(.title2).bold()
                            
                            // Notification Preferences
                            Toggle("Enable Notifications", isOn: $notificationsEnabled)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            
                            // Dark Mode Toggle
                            Toggle("Dark Mode", isOn: $darkModeEnabled)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            
                            // Region Preference
                            VStack(alignment: .leading) {
                                Text("News Region")
                                    .font(.headline)
                                Picker("Region", selection: $selectedRegion) {
                                    Text("India").tag("India")
                                    Text("Global").tag("Global")
                                    Text("Both").tag("Both")
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            
                            Button("Save Preferences") {
                                isUpdatingPreferences = true
                                Task {
                                    do {
                                        try await authService.saveUserPreferences(
                                            notificationsEnabled: notificationsEnabled,
                                            darkModeEnabled: darkModeEnabled,
                                            region: selectedRegion
                                        )
                                        showUserPreferences = false
                                    } catch {
                                        errorMessage = "Failed to save preferences: \(error.localizedDescription)"
                                    }
                                    isUpdatingPreferences = false
                                }
                            }
                            .disabled(isUpdatingPreferences)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(8)
                            
                            if let errorMessage = errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .preferredColorScheme(.dark)
                    }
                    
                    // Profile editing sheet
                    .sheet(isPresented: $showEditProfile) {
                        ZStack {
                            Color.black.ignoresSafeArea()
                            
                            VStack(spacing: 24) {
                                // Header
                                Text("Edit Profile")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.top, 20)
                                
                                Spacer().frame(height: 20)
                                
                                // Profile Photo with upload button
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.1))
                                        .frame(width: 120, height: 120)
                                    
                                    if let url = newPhotoURL {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .transition(.opacity)
                                            case .failure:
                                                Image(systemName: "person.circle.fill")
                                                    .resizable()
                                                    .foregroundColor(.gray)
                                                    .padding(20)
                                            @unknown default:
                                                Image(systemName: "person.circle.fill")
                                                    .resizable()
                                                    .foregroundColor(.gray)
                                                    .padding(20)
                                            }
                                        }
                                        .frame(width: 110, height: 110)
                                        .clipShape(Circle())
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 80, height: 80)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    // Camera upload button
                                    Button(action: {
                                        // Add photo picker logic here
                                        // This would integrate with PhotosUI for image selection
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.blue)
                                                .frame(width: 36, height: 36)
                                            
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 16))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .offset(x: 40, y: 40)
                                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                                }
                                .padding(.bottom, 20)
                                
                                // Display Name Field with floating label
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Display Name")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    
                                    TextField("", text: $newDisplayName)
                                        .font(.system(size: 17))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white.opacity(0.1))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                                        )
                                }
                                .padding(.horizontal, 24)
                                
                                // User Name (optional)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Username (Optional)")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    
                                    HStack {
                                        Text("@")
                                            .foregroundColor(.gray)
                                        
                                        TextField("username", text: .constant(""))
                                            .font(.system(size: 17))
                                            .foregroundColor(.white)
                                    }
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.1))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                                }
                                .padding(.horizontal, 24)
                                
                                // Bio (optional)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Bio (Optional)")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    
                                    TextEditor(text: .constant(""))
                                        .frame(height: 100)
                                        .font(.system(size: 17))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white.opacity(0.1))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                }
                                .padding(.horizontal, 24)
                                
                                Spacer()
                                
                                // Action Buttons
                                HStack(spacing: 16) {
                                    // Cancel Button
                                    Button(action: {
                                        showEditProfile = false
                                    }) {
                                        Text("Cancel")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                            .padding(.vertical, 14)
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.white.opacity(0.1))
                                            )
                                    }
                                    
                                    // Save Button
                                    Button(action: {
                                        isSaving = true
                                        saveError = nil
                                        Task {
                                            do {
                                                try await authService.updateDisplayName(newDisplayName)
                                                // TODO: Add upload photo logic here when implemented
                                                showEditProfile = false
                                            } catch {
                                                saveError = error.localizedDescription
                                            }
                                            isSaving = false
                                        }
                                    }) {
                                        HStack {
                                            if isSaving {
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                                    .scaleEffect(0.8)
                                                    .padding(.trailing, 6)
                                            }
                                            
                                            Text("Save Changes")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.black)
                                        }
                                        .padding(.vertical, 14)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white)
                                        )
                                        .opacity(isSaving ? 0.7 : 1.0)
                                    }
                                    .disabled(isSaving || newDisplayName.isEmpty)
                                }
                                .padding(.horizontal, 24)
                                .padding(.bottom, 32)
                            }
                            
                            // Error message
                            if let error = saveError {
                                VStack {
                                    Spacer()
                                    
                                    Text(error)
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.red.opacity(0.8))
                                        )
                                        .padding(.bottom, 8)
                                        .transition(.move(edge: .bottom).combined(with: .opacity))
                                }
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: saveError)
                                .zIndex(1)
                            }
                        }
                        .presentationDetents([.large])
                    }
                    
                    // App Info
                    ProfileSectionHeader(title: "App Information")
                    
                    // Login Method
                    HStack {
                        Image(systemName: "person.badge.key.fill")
                            .foregroundColor(.green)
                        Text("Login Method:")
                            .foregroundColor(.white)
                        Spacer()
                        if let providerID = authService.user?.providerData.first?.providerID {
                            switch providerID {
                            case "password":
                                Text("Email/Password")
                                    .foregroundColor(.gray)
                            case "google.com":
                                Text("Google")
                                    .foregroundColor(.gray)
                            default:
                                Text(providerID)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    
                    // App Version
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.purple)
                        Text("App Version:")
                            .foregroundColor(.white)
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    
                    // Sign Out Button
                    Button(action: { showSignOutAlert = true }) {
                        Text("Sign Out")
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                    .alert(isPresented: $showSignOutAlert) {
                        Alert(
                            title: Text("Sign Out"),
                            message: Text("Are you sure you want to sign out?"),
                            primaryButton: .destructive(Text("Sign Out")) {
                                try? authService.signOut()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    
                    // Delete Account (danger zone)
                    ProfileSectionHeader(title: "Danger Zone")
                    
                    Button(action: {
                        showDeleteAccount = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                            Text("Delete Account")
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 16)
                    .alert(isPresented: $showDeleteAccount) {
                        Alert(
                            title: Text("Delete Account"),
                            message: Text("This will permanently delete your account and all saved data. This action cannot be undone."),
                            primaryButton: .destructive(Text("Delete")) {
                                isDeletingAccount = true
                                Task {
                                    do {
                                        try await authService.deleteAccount()
                                        // The auth state will change, redirecting to login
                                    } catch {
                                        isDeletingAccount = false
                                        errorMessage = "Failed to delete account: \(error.localizedDescription)"
                                    }
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            Task {
                await loadUserPreferences()
            }
        }
    }
    
    private func loadUserPreferences() async {
        isLoading = true
        do {
            let prefs = try await authService.fetchUserPreferences()
            if let notificationsValue = prefs["notificationsEnabled"] as? Bool {
                notificationsEnabled = notificationsValue
            }
            if let darkModeValue = prefs["darkModeEnabled"] as? Bool {
                darkModeEnabled = darkModeValue
            }
            if let regionValue = prefs["region"] as? String {
                selectedRegion = regionValue
            }
        } catch {
            // Silently fail, using defaults
        }
        isLoading = false
    }
}

// Section Headers for Profile
struct ProfileSectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
        .padding(.bottom, 8)
    }
}

// Add this struct for the profile stats cards
struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.2))
                .clipShape(Circle())
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .offset(y: appear ? 0 : 20)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.1)) {
                appear = true
            }
        }
    }
}

// Add this extension for custom rounded corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    ProfileView()
}

// Add BookmarksProfileView after ProfileSectionHeader struct
struct BookmarksProfileView: View {
    @StateObject private var authService = AuthenticationService.shared
    @State private var articles: [NewsArticle] = []
    @State private var isLoading = true
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showArticle = false
    @State private var selectedArticleURL: URL? = nil
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
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
                        Text("Articles you save will appear here")
                            .foregroundColor(.gray)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(articles) { article in
                                SavedArticleCard(article: article, onRead: {
                                    if let url = URL(string: article.url) {
                                        selectedArticleURL = url
                                        showArticle = true
                                    }
                                }, onRemove: {
                                    removeBookmark(article)
                                })
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Saved Articles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                Task {
                    await loadBookmarks()
                }
            }
            .sheet(isPresented: $showArticle) {
                if let url = selectedArticleURL {
                    SafariView(url: url)
                }
            }
            .alert(isPresented: $showError) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func loadBookmarks() async {
        isLoading = true
        do {
            articles = try await authService.fetchBookmarks()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
    
    private func removeBookmark(_ article: NewsArticle) {
        Task {
            do {
                try await authService.removeBookmark(article)
                // Remove from local list
                if let index = articles.firstIndex(where: { $0.id == article.id }) {
                    articles.remove(at: index)
                }
            } catch {
                errorMessage = "Failed to remove bookmark: \(error.localizedDescription)"
                showError = true
            }
        }
    }
}

struct SavedArticleCard: View {
    let article: NewsArticle
    let onRead: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(article.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(3)
                    
                    Text(article.source)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(article.publishedAt, style: .date)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            HStack {
                Button(action: onRead) {
                    Text("Read Article")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(6)
                }
                
                Spacer()
                
                Button(action: onRemove) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
} 