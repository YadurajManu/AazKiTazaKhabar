import SwiftUI
import CoreLocation

struct OnboardingView: View {
    @State private var step = 0
    @State private var selectedRegion: String? = nil
    @State private var selectedCategories: Set<String> = []
    @State private var allowLocation = false
    @State private var notificationsEnabled = false
    @State private var isSubmitting = false
    @State private var showError = false
    @State private var errorMessage: String? = nil
    @ObservedObject private var authService = AuthenticationService.shared
    @StateObject private var locationManager = LocationManager()
    
    let regions = ["Indian", "Global", "Both"]
    let categories = ["Politics", "Sports", "Technology", "Business", "Entertainment", "Health", "Science"]
    let totalSteps = 6
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                // Step Indicator
                HStack(spacing: 8) {
                    ForEach(0..<totalSteps, id: \.self) { i in
                        Circle()
                            .fill(i <= step ? Color.white : Color.white.opacity(0.15))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: step)
                    }
                }
                .padding(.top, 32)
                Spacer(minLength: 0)
                stepContent
                Spacer(minLength: 0)
                // Navigation Buttons
                HStack {
                    if step > 0 {
                        AnimatedOnboardingButton(label: "Back", selected: false, action: { withAnimation { step -= 1 } }, fontSize: 17, isPrimary: false)
                    }
                    Spacer()
                    if step < 5 {
                        AnimatedOnboardingButton(label: "Next", selected: false, action: {
                            if (step == 1 && selectedRegion == nil) || (step == 2 && selectedCategories.isEmpty) || (step == 3 && allowLocation && locationManager.status == .denied) {
                                showError = true
                                return
                            }
                            showError = false
                            withAnimation { step += 1 }
                        }, fontSize: 17)
                    } else {
                        AnimatedOnboardingButton(label: isSubmitting ? "Loading..." : "Get Started", selected: false, action: {
                            Task {
                                isSubmitting = true
                                errorMessage = nil
                                do {
                                    try await authService.saveOnboarding(
                                        region: selectedRegion ?? "",
                                        categories: Array(selectedCategories),
                                        notifications: notificationsEnabled
                                    )
                                    // Optionally, save location
                                    if allowLocation, let loc = locationManager.lastLocation {
                                        try await authService.saveUserLocation(loc)
                                    }
                                } catch {
                                    errorMessage = error.localizedDescription
                                }
                                isSubmitting = false
                            }
                        }, fontSize: 17, isPrimary: true, loading: isSubmitting)
                        .disabled(isSubmitting)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 36)
                // Error Message
                if showError {
                    Text("Please answer the question to continue.")
                        .foregroundColor(.red)
                        .font(.footnote)
                        .transition(.opacity)
                }
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: 500)
            .padding(.vertical, 0)
        }
    }
    
    @ViewBuilder
    var stepContent: some View {
        switch step {
        case 0:
            WelcomeStepView()
        case 1:
            RegionStepView(regions: regions, selectedRegion: $selectedRegion)
        case 2:
            CategoryStepView(categories: categories, selectedCategories: $selectedCategories)
        case 3:
            LocationStepView(allowLocation: $allowLocation, locationManager: locationManager)
        case 4:
            NotificationStepView(notificationsEnabled: $notificationsEnabled)
        case 5:
            ConfirmationStepView()
        default:
            EmptyView()
        }
    }
}

struct WelcomeStepView: View {
    @State private var appearLogo = false
    @State private var appearTitle = false
    @State private var appearSubtitle = false
    
    var body: some View {
        VStack(spacing: 30) {
            // App logo animation
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 120, height: 120)
                    .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    .scaleEffect(appearLogo ? 1 : 0.5)
                    .opacity(appearLogo ? 1 : 0)
                
                Image(systemName: "newspaper.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
                    .scaleEffect(appearLogo ? 1 : 0.3)
                    .opacity(appearLogo ? 1 : 0)
            }
            .padding(.bottom, 20)
            
            // Title with typing effect
            Text("Welcome to AazKiTazaKhabar")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .opacity(appearTitle ? 1 : 0)
                .offset(y: appearTitle ? 0 : 20)
            
            // Subtitle
            Text("Your personalized news experience starts here.\nGet the latest news tailored to your interests.")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .opacity(appearSubtitle ? 1 : 0)
                .offset(y: appearSubtitle ? 0 : 10)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 30)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appearLogo = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
                appearTitle = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.8)) {
                appearSubtitle = true
            }
        }
    }
}

struct RegionStepView: View {
    let regions: [String]
    @Binding var selectedRegion: String?
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Text("Which news region")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("do you prefer?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 20)
            .offset(y: appear ? 0 : 30)
            .opacity(appear ? 1 : 0)
            
            ForEach(Array(regions.enumerated()), id: \.element) { index, region in
                AnimatedOnboardingButton(
                    label: region,
                    selected: selectedRegion == region,
                    action: { 
                        withAnimation(.spring()) {
                            selectedRegion = region
                        }
                    }
                )
                .offset(y: appear ? 0 : 50 + 20 * Double(index))
                .opacity(appear ? 1 : 0)
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 16)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appear = true
            }
        }
    }
}

struct CategoryStepView: View {
    let categories: [String]
    @Binding var selectedCategories: Set<String>
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select your favorite categories")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .offset(y: appear ? 0 : 30)
                .opacity(appear ? 1 : 0)
            
            // Grid layout for categories
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(Array(categories.enumerated()), id: \.element) { index, category in
                    CategoryButton(
                        label: category,
                        selected: selectedCategories.contains(category),
                        action: {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                if selectedCategories.contains(category) {
                                    selectedCategories.remove(category)
                                } else {
                                    selectedCategories.insert(category)
                                }
                            }
                        }
                    )
                    .offset(y: appear ? 0 : 50)
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.1 * Double(index % 4)), value: appear)
                }
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 16)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeOut(duration: 0.4)) {
                    appear = true
                }
            }
        }
    }
}

struct CategoryButton: View {
    let label: String
    let selected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: categoryIcon(for: label))
                    .foregroundColor(selected ? .white : .blue)
                    .font(.system(size: 14))
                
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(selected ? .white : .blue)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(selected ? Color.blue : Color.blue.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selected ? Color.clear : Color.blue.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(selected ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func categoryIcon(for category: String) -> String {
        switch category.lowercased() {
        case "politics": return "building.columns.fill"
        case "sports": return "sportscourt.fill"
        case "technology": return "laptopcomputer"
        case "business": return "chart.bar.fill"
        case "entertainment": return "film.fill"
        case "health": return "heart.fill"
        case "science": return "atom"
        default: return "newspaper.fill"
        }
    }
}

struct LocationStepView: View {
    @Binding var allowLocation: Bool
    @ObservedObject var locationManager: LocationManager
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: allowLocation ? "mappin.and.ellipse" : "mappin.slash")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(.white)
                .padding(.bottom, 8)
            Text("Allow location for local news?")
                .font(.custom("SpaceGrotesk", size: 24).weight(.bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Text("We'll use your location to show you news relevant to your area. You can always change this later.")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)
            Toggle(isOn: $allowLocation) {
                Text(allowLocation ? "Yes, enable location" : "No, thanks")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
            }
            .toggleStyle(SwitchToggleStyle(tint: .white))
            .padding(.horizontal, 40)
            .onChange(of: allowLocation) { newValue in
                if newValue {
                    locationManager.requestLocation()
                }
            }
            if allowLocation && locationManager.status == .denied {
                Text("Location permission denied. Please enable it in Settings.")
                    .foregroundColor(.red)
                    .font(.footnote)
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 16)
    }
}

struct NotificationStepView: View {
    @Binding var notificationsEnabled: Bool
    var body: some View {
        VStack(spacing: 20) {
            Text("Enable notifications for breaking news?")
                .font(.custom("SpaceGrotesk", size: 24).weight(.bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Toggle(isOn: $notificationsEnabled) {
                Text(notificationsEnabled ? "Yes" : "No")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
            }
            .toggleStyle(SwitchToggleStyle(tint: .white))
            .padding()
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 16)
    }
}

struct ConfirmationStepView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("You're all set!")
                .font(.custom("SpaceGrotesk", size: 30).weight(.bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Text("Tap below to start reading personalized news.")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 16)
    }
}

// Location Manager for onboarding
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var status: CLAuthorizationStatus = .notDetermined
    @Published var lastLocation: CLLocationCoordinate2D? = nil
    override init() {
        super.init()
        manager.delegate = self
    }
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.status = status
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.lastLocation = locations.last?.coordinate
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}

struct AnimatedOnboardingButton: View {
    let label: String
    let selected: Bool
    let action: () -> Void
    var fontSize: CGFloat = 18
    var isPrimary: Bool = false
    var loading: Bool = false
    @State private var pressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                pressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    pressed = false
                }
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                action()
            }
        }) {
            HStack {
                if loading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: isPrimary ? .black : .white))
                        .scaleEffect(0.8)
                        .padding(.trailing, 8)
                }
                
                Text(label)
                    .font(.system(size: fontSize, weight: .semibold))
                    .foregroundColor(isPrimary ? .black : (selected ? .blue : .white))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isPrimary ? Color.white :
                            (selected ? Color.blue.opacity(0.2) : Color.white.opacity(0.1))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selected && !isPrimary ? Color.blue : Color.clear, lineWidth: 2)
            )
            .shadow(color: isPrimary ? Color.white.opacity(0.3) : Color.clear, radius: 5, x: 0, y: 2)
            .scaleEffect(pressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    OnboardingView()
} 
