import SwiftUI
import UIKit

struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var isPushingVerify: Bool = false
    @State private var errorMessage: LocalizedStringKey?
    @EnvironmentObject var appVM: AppViewModel
    @EnvironmentObject var container: AppContainer
    var onSwitchToSignUp: () -> Void = {}

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            header
            VStack(alignment: .center, spacing: 16) {
                AppTextField(
                    label: "Email",
                    placeholder: "you@example.com",
                    text: $email,
                    isSecure: false,
                    keyboardType: .emailAddress,
                    contentType: .emailAddress,
                    submitLabel: .next,
                    size: .large,
                    leadingSystemImage: "envelope",
                    error: emailError,
                    onSubmit: {},
                    preventAutoLinkStyling: true,
                    placeholderKeyForMask: "you@example.com"
                )
                AppTextField(
                    label: "Password",
                    placeholder: "Enter your password",
                    text: $password,
                    isSecure: true,
                    keyboardType: .default,
                    contentType: .password,
                    submitLabel: .go,
                    size: .large,
                    leadingSystemImage: "lock",
                    error: passwordError,
                    onSubmit: { signIn() }
                )
                HStack {
                    Button("Forgot password?") {}
                        .buttonStyle(.plain)
                        .tint(.secondary)
                    Spacer()
                    Button(action: { onSwitchToSignUp() }) { Text("Sign up instead").underline() }
                        .buttonStyle(.plain)
                        .tint(.primary)
                }
            }
            Spacer()
            Group {
                PrimaryButton(title: "Sign in", isLoading: isLoading, isDisabled: !canSubmit) {
                    signIn()
                }
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            }
        }
        .sheet(isPresented: $isPushingVerify) { VerifyOtpView(email: email) }
    }

    private var header: some View {
        VStack(alignment: .center, spacing: 16) {
            VStack(alignment: .center, spacing: 4) {
                Text("Welcome to Sawaed")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color(.label))
                Text("Sign in to Continue")
                    .font(.headline)
                    .foregroundStyle(Color(.label))
            }
        }
    }

    private var emailError: LocalizedStringKey? {
        if email.isEmpty { return nil }
        return isValidEmail(email) ? nil : "Please enter a valid email address"
    }

    private var passwordError: LocalizedStringKey? {
        if password.isEmpty { return nil }
        return password.count >= 6 ? nil : "Password must be at least 6 characters"
    }

    private var canSubmit: Bool {
        isValidEmail(email) && password.count >= 6
    }

    private func signIn() {
        guard canSubmit else { return }
        isLoading = true
        errorMessage = nil
        Task {
            do {
                // For now use OTP flow until password sign-in endpoint exists
                try await container.auth.requestOtp(email: email)
                isPushingVerify = true
            } catch {
                errorMessage = "Failed to sign in"
            }
            isLoading = false
        }
    }

    private func isValidEmail(_ value: String) -> Bool {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return value.range(of: pattern, options: .regularExpression) != nil
    }

}

#Preview {
    let baseURL = URL(string: "https://sawaed.tareq.pro")!
    let keychain = KeychainStore()
    let defaults = UserDefaultsStore()
    let tokenMediator = TokenMediator(keychain: keychain, baseURL: baseURL)
    let httpClient = HTTPClient(baseURL: baseURL, tokenProvider: tokenMediator)
    let authService = AuthService(http: httpClient, keychain: keychain)
    let onboardingService = OnboardingService(http: httpClient)
    let profileService = ProfileService(http: httpClient)
    let container = AppContainer(keychain: keychain, defaults: defaults, http: httpClient, auth: authService, onboarding: onboardingService, profile: profileService)
    return SignInView()
        .environmentObject(AppViewModel())
        .environmentObject(container)
}
