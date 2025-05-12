import SwiftUI

struct LoginView: View {
    @StateObject private var authService = AuthenticationService.shared
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @FocusState private var focusedField: Field?
    @State private var showTitle = false
    @State private var animatedTitle = ""
    @State private var showForm = false
    @Namespace private var animation
    
    enum Field { case email, password }
    let appTitle = "AazKiTazaKhabar"
    let typewriterSpeed = 0.07
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 36) {
                Spacer(minLength: 40)
                // App Title with Typewriter Effect
                HStack(spacing: 0) {
                    ForEach(Array(animatedTitle), id: \.self) { char in
                        Text(String(char))
                            .font(.custom("SpaceGrotesk", size: 36))
                            .foregroundColor(.white)
                            .transition(.opacity)
                    }
                }
                .onAppear {
                    showTypewriterTitle()
                }
                .padding(.bottom, 8)
                // Subtitle
                if showTitle {
                    Text(isSignUp ? "Create your account" : "Sign in to continue")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .padding(.bottom, 24)
                        .transition(.opacity)
                }
                // Animated Form
                if showForm {
                    VStack(spacing: 20) {
                        MinimalTextField(
                            text: $email,
                            placeholder: "Email",
                            systemImage: "envelope",
                            isSecure: false
                        )
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }
                        MinimalTextField(
                            text: $password,
                            placeholder: "Password",
                            systemImage: "lock",
                            isSecure: true
                        )
                        .focused($focusedField, equals: .password)
                        .submitLabel(.go)
                    }
                    .padding(.horizontal, 32)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                // Animated Error Message
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top, -10)
                        .padding(.bottom, 4)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                // Main Button with Tap Animation
                if showForm {
                    AnimatedButton(isLoading: isLoading, label: isSignUp ? "Sign Up" : "Sign In", fontName: "SpaceGrotesk") {
                        errorMessage = nil
                        isLoading = true
                        Task {
                            do {
                                if isSignUp {
                                    try await authService.signUp(email: email, password: password)
                                } else {
                                    try await authService.signIn(email: email, password: password)
                                }
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                            isLoading = false
                        }
                    }
                    .padding(.horizontal, 32)
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    .transition(.scale)
                }
                // Google Sign In Button
                if showForm {
                    AnimatedButton(isLoading: false, label: "Continue with Google", icon: "g.circle.fill", dark: true, fontName: "SpaceGrotesk") {
                        errorMessage = nil
                        isLoading = true
                        Task {
                            do {
                                try await authService.signInWithGoogle()
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                            isLoading = false
                        }
                    }
                    .padding(.horizontal, 32)
                    .disabled(isLoading)
                    .transition(.scale)
                }
                // Toggle Sign In/Up
                if showForm {
                    HStack {
                        Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                            .foregroundColor(.gray)
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                isSignUp.toggle()
                                errorMessage = nil
                            }
                        }) {
                            Text(isSignUp ? "Sign In" : "Sign Up")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .underline()
                        }
                    }
                    .font(.footnote)
                    .padding(.top, 8)
                    .transition(.opacity)
                }
                Spacer(minLength: 40)
            }
            .onAppear {
                withAnimation(.easeInOut.delay(Double(appTitle.count) * typewriterSpeed + 0.2)) {
                    showTitle = true
                }
                withAnimation(.easeInOut.delay(Double(appTitle.count) * typewriterSpeed + 0.5)) {
                    showForm = true
                }
            }
        }
    }
    // Typewriter animation for the title
    private func showTypewriterTitle() {
        animatedTitle = ""
        for (i, char) in appTitle.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * typewriterSpeed) {
                animatedTitle.append(char)
            }
        }
    }
}

struct AnimatedButton: View {
    var isLoading: Bool
    var label: String
    var icon: String? = nil
    var dark: Bool = false
    var fontName: String? = nil
    var action: () -> Void
    @State private var pressed = false
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.12)) { pressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.12)) { pressed = false }
                action()
            }
        }) {
            HStack(spacing: 10) {
                if let icon = icon {
                    Image(systemName: icon)
                        .resizable()
                        .frame(width: 22, height: 22)
                }
                if isLoading {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: dark ? .white : .black)).scaleEffect(0.8)
                }
                Text(label)
                    .font(fontName != nil ? .custom(fontName!, size: 18) : .headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(dark ? Color.black : Color.white)
            .foregroundColor(dark ? .white : .black)
            .cornerRadius(14)
            .shadow(color: .white.opacity(0.04), radius: 8, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(dark ? Color.white : Color.clear, lineWidth: 1.2)
            )
            .scaleEffect(pressed ? 0.97 : 1.0)
            .opacity(pressed ? 0.85 : 1.0)
        }
        .disabled(isLoading)
    }
}

struct MinimalTextField: View {
    @Binding var text: String
    let placeholder: String
    let systemImage: String
    var isSecure: Bool = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(.gray)
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .focused($isFocused)
                } else {
                    TextField(placeholder, text: $text)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .focused($isFocused)
                }
            }
            Rectangle()
                .frame(height: 1.2)
                .foregroundColor(isFocused ? .white : .white.opacity(text.isEmpty ? 0.15 : 0.8))
                .animation(.easeInOut, value: isFocused)
        }
    }
}

#Preview {
    LoginView()
} 