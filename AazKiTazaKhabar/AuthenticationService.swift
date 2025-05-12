import Foundation
import Firebase
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore
import CoreLocation

@MainActor
class AuthenticationService: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var onboardingComplete = false
    
    static let shared = AuthenticationService()
    private let db = Firestore.firestore()
    
    private init() {
        // Listen for authentication state changes
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            self?.isAuthenticated = user != nil
            if let user = user {
                Task { await self?.fetchOnboardingStatus(for: user.uid) }
            } else {
                self?.onboardingComplete = false
            }
        }
    }
        
    // Check onboarding status in Firestore
    func fetchOnboardingStatus(for uid: String) async {
        do {
            let doc = try await db.collection("users").document(uid).collection("profile").document("onboarding").getDocument()
            if let data = doc.data(), let complete = data["onboardingComplete"] as? Bool {
                self.onboardingComplete = complete
            } else {
                self.onboardingComplete = false
            }
        } catch {
            self.onboardingComplete = false
        }
    }
    
    // Save onboarding data to Firestore
    func saveOnboarding(region: String, categories: [String], notifications: Bool) async throws {
        guard let uid = user?.uid else { return }
        let data: [String: Any] = [
            "region": region,
            "categories": categories,
            "notifications": notifications,
            "onboardingComplete": true
        ]
        try await db.collection("users").document(uid).collection("profile").document("onboarding").setData(data)
        self.onboardingComplete = true
    }
    
    // Save user location to Firestore
    func saveUserLocation(_ location: CLLocationCoordinate2D) async throws {
        guard let uid = user?.uid else { return }
        let data: [String: Any] = [
            "latitude": location.latitude,
            "longitude": location.longitude
        ]
        try await db.collection("users").document(uid).collection("profile").document("location").setData(data)
    }
    
    // Sign in with email and password
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.user = result.user
            self.isAuthenticated = true
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // Sign up with email and password
    func signUp(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.user = result.user
            self.isAuthenticated = true
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // Sign in with Google
    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Ensure presentation is on main thread
        var rootViewController: UIViewController?
        await MainActor.run {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                rootViewController = window.rootViewController
            }
        }
        guard let presentingVC = rootViewController else { return }
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC)
            guard let idToken = result.user.idToken?.tokenString else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: result.user.accessToken.tokenString)
            let authResult = try await Auth.auth().signIn(with: credential)
            self.user = authResult.user
            self.isAuthenticated = true
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // Sign out
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.isAuthenticated = false
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // Update display name
    func updateDisplayName(_ name: String) async throws {
        guard let user = Auth.auth().currentUser else { return }
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = name
        try await changeRequest.commitChanges()
        self.user = Auth.auth().currentUser
        // Optionally update in Firestore as well
        let uid = user.uid
        try await db.collection("users").document(uid).setData(["displayName": name], merge: true)
    }
    
    // Change password for email/password users
    func changePassword(currentPassword: String, newPassword: String) async throws {
        guard let user = Auth.auth().currentUser, let email = user.email else { throw NSError(domain: "No user", code: 0) }
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        // Re-authenticate
        try await user.reauthenticate(with: credential)
        // Update password
        try await user.updatePassword(to: newPassword)
    }
    
    // MARK: - Bookmarks (Firestore)
    func addBookmark(_ article: NewsArticle) async throws {
        guard let uid = user?.uid else { return }
        let docRef = db.collection("users").document(uid).collection("bookmarks").document(article.id.uuidString)
        let data: [String: Any] = [
            "id": article.id.uuidString,
            "title": article.title,
            "description": article.description,
            "url": article.url,
            "imageUrl": article.imageUrl ?? "",
            "source": article.source,
            "publishedAt": article.publishedAt.timeIntervalSince1970
        ]
        try await docRef.setData(data)
    }

    func removeBookmark(_ article: NewsArticle) async throws {
        guard let uid = user?.uid else { return }
        let docRef = db.collection("users").document(uid).collection("bookmarks").document(article.id.uuidString)
        try await docRef.delete()
    }

    func fetchBookmarks() async throws -> [NewsArticle] {
        guard let uid = user?.uid else { return [] }
        let snapshot = try await db.collection("users").document(uid).collection("bookmarks").getDocuments()
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            guard let title = data["title"] as? String,
                  let description = data["description"] as? String,
                  let url = data["url"] as? String,
                  let source = data["source"] as? String,
                  let publishedAt = data["publishedAt"] as? TimeInterval else { return nil }
            let imageUrl = data["imageUrl"] as? String
            return NewsArticle(
                title: title,
                description: description,
                url: url,
                imageUrl: imageUrl?.isEmpty == false ? imageUrl : nil,
                source: source,
                publishedAt: Date(timeIntervalSince1970: publishedAt)
            )
        }
    }
    
    func isBookmarked(_ article: NewsArticle) async throws -> Bool {
        guard let uid = user?.uid else { return false }
        let docRef = db.collection("users").document(uid).collection("bookmarks").document(article.id.uuidString)
        let doc = try await docRef.getDocument()
        return doc.exists
    }
    
    func getBookmarkCount() async throws -> Int {
        guard let uid = user?.uid else { return 0 }
        let snapshot = try await db.collection("users").document(uid).collection("bookmarks").getDocuments()
        return snapshot.documents.count
    }
    
    // MARK: - User Preferences
    func saveUserPreferences(notificationsEnabled: Bool, darkModeEnabled: Bool, region: String) async throws {
        guard let uid = user?.uid else { return }
        let data: [String: Any] = [
            "notificationsEnabled": notificationsEnabled,
            "darkModeEnabled": darkModeEnabled,
            "region": region
        ]
        try await db.collection("users").document(uid).collection("profile").document("preferences").setData(data)
    }
    
    func fetchUserPreferences() async throws -> [String: Any] {
        guard let uid = user?.uid else { return [:] }
        let doc = try await db.collection("users").document(uid).collection("profile").document("preferences").getDocument()
        return doc.data() ?? [:]
    }
    
    // MARK: - Delete Account
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { return }
        
        // First, delete user data from Firestore
        let uid = user.uid
        // Delete bookmarks
        let bookmarksSnapshot = try await db.collection("users").document(uid).collection("bookmarks").getDocuments()
        for document in bookmarksSnapshot.documents {
            try await document.reference.delete()
        }
        
        // Delete preferences
        try await db.collection("users").document(uid).collection("profile").document("preferences").delete()
        
        // Delete onboarding data
        try await db.collection("users").document(uid).collection("profile").document("onboarding").delete()
        
        // Delete user document itself
        try await db.collection("users").document(uid).delete()
        
        // Finally, delete the Firebase Auth account
        try await user.delete()
        
        // Clear local state
        self.user = nil
        self.isAuthenticated = false
    }
} 