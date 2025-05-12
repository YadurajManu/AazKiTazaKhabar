//
//  AazKiTazaKhabarApp.swift
//  AazKiTazaKhabar
//
//  Created by Yaduraj Singh on 08/05/25.
//

import SwiftUI
import Firebase

@main
struct AazKiTazaKhabarApp: App {
    @StateObject private var authService = AuthenticationService.shared
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                if !authService.onboardingComplete {
                    OnboardingView()
                } else {
                    MainView()
                }
            } else {
                LoginView()
            }
        }
    }
}
