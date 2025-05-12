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
    @State private var bookmarkCount = 0
    
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
                                    gradient: Gradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)]),
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
                                    .fill(Color.white.opacity(0.05))
                                    .frame(width: 110, height: 110)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.white.opacity(0.2), .white.opacity(0.05)]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                                
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
                                    .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                // Edit profile button overlay
                                Button(action: {
                                    newDisplayName = authService.user?.displayName ?? ""
                                    newPhotoURL = authService.user?.photoURL
                                    showEditProfile = true
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.black)
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                            )
                                        
                                        Image(systemName: "pencil")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                }
                                .buttonStyle(ScaleButtonStyle())
                                .offset(x: 35, y: 35)
                            }
                            .padding(.top, 30)
                            
                            // Name with improved typography
                            Text(authService.user?.displayName ?? "No Name")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            
                            // Email with subtle styling
                            Text(authService.user?.email ?? "No email")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.bottom, 12)
                        }
                        .padding(.top, 20)
                    }
                    .padding(.bottom, 20)
                    
                    // Stats section
                    HStack(spacing: 0) {
                        StatCard(value: "0", label: "Articles Read", icon: "book.fill", color: .blue)
                        StatCard(value: "\(bookmarkCount)", label: "Bookmarks", icon: "bookmark.fill", color: .orange)
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
                            Image(systemName: "bookmark")
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                            Text("Saved Articles")
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.5))
                                .font(.system(size: 14))
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.03))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.white.opacity(0.1), .white.opacity(0.05)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.5
                                )
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal, 16)
                    .sheet(isPresented: $showBookmarks) {
                        BookmarksProfileView()
                    }
                    
                    // User Preferences
                    Button(action: {
                        showUserPreferences = true
                    }) {
                        HStack {
                            Image(systemName: "gearshape")
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                            Text("App Preferences")
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.5))
                                .font(.system(size: 14))
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.03))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.white.opacity(0.1), .white.opacity(0.05)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.5
                                )
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal, 16)
                    .sheet(isPresented: $showUserPreferences) {
                        ZStack {
                            Color.black.ignoresSafeArea()
                            
                            VStack(spacing: 0) {
                                // Header with close button
                                HStack {
                                    Text("App Preferences")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        showUserPreferences = false
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 24)
                                .padding(.bottom, 20)
                                
                                ScrollView {
                                    VStack(spacing: 24) {
                                        // Appearance Section
                                        PreferenceSection(title: "Appearance") {
                                            // Theme preference (light/dark)
                                            HStack {
                                                Image(systemName: "moon.fill")
                                                    .foregroundColor(.purple)
                                                    .frame(width: 30)
                                                
                                                Text("Dark Mode")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.white)
                                                
                                                Spacer()
                                                
                                                Toggle("", isOn: $darkModeEnabled)
                                                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                                                    .labelsHidden()
                                            }
                                            .padding()
                                            .background(Color.white.opacity(0.08))
                                            .cornerRadius(12)
                                            
                                            // Text Size
                                            HStack {
                                                Image(systemName: "textformat.size")
                                                    .foregroundColor(.blue)
                                                    .frame(width: 30)
                                                
                                                Text("Text Size")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.white)
                                                
                                                Spacer()
                                                
                                                Picker("", selection: .constant(2)) {
                                                    Text("Small").tag(1)
                                                    Text("Medium").tag(2)
                                                    Text("Large").tag(3)
                                                }
                                                .pickerStyle(SegmentedPickerStyle())
                                                .frame(width: 180)
                                            }
                                            .padding()
                                            .background(Color.white.opacity(0.08))
                                            .cornerRadius(12)
                                        }
                                        
                                        // Notifications Section
                                        PreferenceSection(title: "Notifications") {
                                            // Push notifications toggle
                                            HStack {
                                                Image(systemName: "bell.fill")
                                                    .foregroundColor(.orange)
                                                    .frame(width: 30)
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text("Push Notifications")
                                                        .font(.system(size: 16))
                                                        .foregroundColor(.white)
                                                    
                                                    Text("Get real-time news alerts")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.gray)
                                                }
                                                
                                                Spacer()
                                                
                                                Toggle("", isOn: $notificationsEnabled)
                                                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                                                    .labelsHidden()
                                            }
                                            .padding()
                                            .background(Color.white.opacity(0.08))
                                            .cornerRadius(12)
                                            
                                            // Breaking news toggle
                                            HStack {
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .foregroundColor(.red)
                                                    .frame(width: 30)
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text("Breaking News Only")
                                                        .font(.system(size: 16))
                                                        .foregroundColor(.white)
                                                    
                                                    Text("Limit alerts to breaking news")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.gray)
                                                }
                                                
                                                Spacer()
                                                
                                                Toggle("", isOn: .constant(true))
                                                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                                                    .labelsHidden()
                                                    .disabled(!notificationsEnabled)
                                            }
                                            .padding()
                                            .background(Color.white.opacity(0.08))
                                            .cornerRadius(12)
                                            .opacity(notificationsEnabled ? 1 : 0.5)
                                        }
                                        
                                        // Content Section
                                        PreferenceSection(title: "Content") {
                                            // Region preference
                                            VStack(alignment: .leading, spacing: 8) {
                                                HStack {
                                                    Image(systemName: "globe")
                                                        .foregroundColor(.green)
                                                        .frame(width: 30)
                                                    
                                                    Text("News Region")
                                                        .font(.system(size: 16))
                                                        .foregroundColor(.white)
                                                    
                                                    Spacer()
                                                }
                                                
                                                HStack(spacing: 10) {
                                                    ForEach(["India", "Global", "Both"], id: \.self) { region in
                                                        Button(action: {
                                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                                selectedRegion = region
                                                            }
                                                        }) {
                                                            Text(region)
                                                                .font(.system(size: 14, weight: selectedRegion == region ? .semibold : .regular))
                                                                .foregroundColor(selectedRegion == region ? .black : .white)
                                                                .padding(.horizontal, 16)
                                                                .padding(.vertical, 8)
                                                                .background(
                                                                    RoundedRectangle(cornerRadius: 20)
                                                                        .fill(selectedRegion == region ? Color.white : Color.white.opacity(0.1))
                                                                )
                                                        }
                                                        .buttonStyle(PlainButtonStyle())
                                                    }
                                                }
                                            }
                                            .padding()
                                            .background(Color.white.opacity(0.08))
                                            .cornerRadius(12)
                                            
                                            // Language preference
                                            HStack {
                                                Image(systemName: "character.bubble")
                                                    .foregroundColor(.cyan)
                                                    .frame(width: 30)
                                                
                                                Text("Language")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.white)
                                                
                                                Spacer()
                                                
                                                Menu {
                                                    Button("English", action: {})
                                                    Button("Hindi", action: {})
                                                    Button("Telugu", action: {})
                                                    Button("Tamil", action: {})
                                                    Button("Bengali", action: {})
                                                } label: {
                                                    HStack {
                                                        Text("English")
                                                        Image(systemName: "chevron.down")
                                                            .font(.system(size: 14))
                                                    }
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(Color.white.opacity(0.1))
                                                    .cornerRadius(8)
                                                }
                                            }
                                            .padding()
                                            .background(Color.white.opacity(0.08))
                                            .cornerRadius(12)
                                        }
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.bottom, 100)
                                }
                                
                                // Save Button Area (fixed at bottom)
                                VStack {
                                    Divider()
                                        .background(Color.white.opacity(0.1))
                                    
                                    HStack {
                                        Button(action: {
                                            showUserPreferences = false
                                        }) {
                                            Text("Cancel")
                                                .foregroundColor(.white)
                                                .padding(.vertical, 14)
                                                .frame(maxWidth: .infinity)
                                                .background(Color.white.opacity(0.1))
                                                .cornerRadius(12)
                                        }
                                        
                                        Button(action: {
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
                                        }) {
                                            HStack {
                                                if isUpdatingPreferences {
                                                    ProgressView()
                                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                                        .scaleEffect(0.8)
                                                        .padding(.trailing, 6)
                                            }
                                                
                                                Text("Save")
                                                    .foregroundColor(.black)
                                            }
                                            .padding(.vertical, 14)
                                            .frame(maxWidth: .infinity)
                                            .background(Color.white)
                                            .cornerRadius(12)
                                            .opacity(isUpdatingPreferences ? 0.7 : 1.0)
                                        }
                                        .disabled(isUpdatingPreferences)
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 16)
                                    .background(Color.black)
                                }
                            }
                            
                            // Error message
                            if let errorMessage = errorMessage {
                                VStack {
                                    Spacer()
                                    
                                    Text(errorMessage)
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
                                .padding(.bottom, 90)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: errorMessage)
                                .zIndex(1)
                            }
                        }
                        .presentationDetents([.large])
                    }
                    
                    // App Info
                    ProfileSectionHeader(title: "App Information")
                    
                    // Login Method
                    HStack {
                        Image(systemName: "person.badge.key")
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                        Text("Login Method:")
                            .foregroundColor(.white)
                        Spacer()
                        if let providerID = authService.user?.providerData.first?.providerID {
                            switch providerID {
                            case "password":
                                Text("Email/Password")
                                    .foregroundColor(.white.opacity(0.6))
                            case "google.com":
                                Text("Google")
                                    .foregroundColor(.white.opacity(0.6))
                            default:
                                Text(providerID)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.03))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white.opacity(0.1), .white.opacity(0.05)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    )
                    .padding(.horizontal, 16)
                    
                    // App Version
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                        Text("App Version:")
                            .foregroundColor(.white)
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.03))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white.opacity(0.1), .white.opacity(0.05)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    )
                    .padding(.horizontal, 16)
                    
                    // Sign Out Button
                    Button(action: { showSignOutAlert = true }) {
                        Text("Sign Out")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
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
                            Image(systemName: "trash")
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                            Text("Delete Account")
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [.white.opacity(0.2), .white.opacity(0.05)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 0.5
                                        )
                                )
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
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
            
            // Listen for bookmark count changes
            NotificationCenter.default.addObserver(forName: NSNotification.Name("BookmarkCountChanged"), object: nil, queue: .main) { _ in
                Task {
                    await fetchBookmarkCount()
                }
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
            
            // Also fetch bookmark count
            await fetchBookmarkCount()
        } catch {
            // Silently fail, using defaults
        }
        isLoading = false
    }
    
    private func fetchBookmarkCount() async {
        do {
            let count = try await authService.getBookmarkCount()
            bookmarkCount = count
        } catch {
            // Silently fail, keep default value
        }
    }
}

// Section Headers for Profile
struct ProfileSectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .tracking(0.5)
            
            Spacer()
            
            Rectangle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [.white.opacity(0.1), .white.opacity(0.05)]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(height: 0.5)
                .frame(maxWidth: 120)
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
        .padding(.bottom, 10)
    }
}

// Add this struct for the profile stats cards
struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color // Keeping for backward compatibility
    @State private var appear = false
    @State private var hover = false
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .light))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.05))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .scaleEffect(hover ? 1.05 : 1.0)
                .shadow(color: Color.white.opacity(hover ? 0.1 : 0), radius: 10, x: 0, y: 5)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.white.opacity(0.1), .white.opacity(0.05)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .offset(y: appear ? 0 : 20)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.1)) {
                appear = true
            }
        }
        .hoverEffect($hover)
    }
}

// Add this extension for custom rounded corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    // Safe hover effect that works on macOS and is silent on iOS
    @ViewBuilder func hoverEffect(_ isHovering: Binding<Bool>) -> some View {
        #if os(macOS)
        self.onHover { hover in
            isHovering.wrappedValue = hover
        }
        #else
        self
        #endif
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

// Button style with scale animation for better interaction feedback
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .brightness(configuration.isPressed ? 0.05 : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
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
    @State private var listRefreshTrigger = false
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
                    .refreshable {
                        await loadBookmarks()
                    }
                }
            }
            .navigationTitle("Saved Articles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .medium))
                            Text("Back")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Saved Articles")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
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
                
                // Update UI on main thread
                await MainActor.run {
                    // Remove from local list for immediate feedback
                    if let index = articles.firstIndex(where: { $0.id == article.id }) {
                        articles.remove(at: index)
                    }
                    
                    // Success haptic feedback
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                    // Trigger parent profile view to refresh bookmark count
                    NotificationCenter.default.post(name: NSNotification.Name("BookmarkCountChanged"), object: nil)
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
    @State private var isRemoving = false
    @State private var isHovering = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                if let imageUrl = article.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.white.opacity(0.05))
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                                )
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                                .clipped()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                                )
                        case .failure:
                            Rectangle()
                                .fill(Color.white.opacity(0.05))
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                                )
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.white.opacity(0.3))
                                )
                        @unknown default:
                            Rectangle()
                                .fill(Color.white.opacity(0.05))
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                        }
                    }
                } else {
                    Rectangle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                        )
                        .overlay(
                            Image(systemName: "newspaper")
                                .foregroundColor(.white.opacity(0.3))
                        )
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(article.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(3)
                    
                    HStack {
                        Text(article.source)
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(.gray)
                        
                        Text(article.detectedCategory)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(categoryColor(article.detectedCategory))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(8)
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                        Text(article.publishedAt, style: .date)
                            .font(.system(size: 10, weight: .light))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.leading, 8)
            }
            
            HStack {
                Button(action: onRead) {
                    Text("Read Article")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                                )
                        )
                }
                .buttonStyle(ScaleButtonStyle())
                
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
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .frame(width: 20, height: 20)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                            )
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(isRemoving)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(isHovering ? 0.05 : 0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.white.opacity(0.1), .white.opacity(0.05)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
        .hoverEffect($isHovering)
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

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// Add this helper view for preference sections
struct PreferenceSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
                .padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                content
            }
        }
    }
} 