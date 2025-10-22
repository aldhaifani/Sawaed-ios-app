import SwiftUI
import UIKit

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var isPushingVerify: Bool = false
    @State private var errorMessage: LocalizedStringKey?
    @EnvironmentObject var appVM: AppViewModel
    @EnvironmentObject var container: AppContainer
    var onSwitchToSignIn: () -> Void = {}

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
                    preventAutoLinkStyling: true,
                    placeholderKeyForMask: "you@example.com"
                )
                AppTextField(
                    label: "Password",
                    placeholder: "Create a password",
                    text: $password,
                    isSecure: true,
                    keyboardType: .default,
                    contentType: .newPassword,
                    submitLabel: .next,
                    size: .large,
                    leadingSystemImage: "lock",
                    error: passwordError
                )
                AppTextField(
                    label: "Confirm Password",
                    placeholder: "Re-enter your password",
                    text: $confirmPassword,
                    isSecure: true,
                    keyboardType: .default,
                    contentType: .newPassword,
                    submitLabel: .go,
                    size: .large,
                    leadingSystemImage: "lock.rotation.open",
                    error: confirmPasswordError,
                    onSubmit: { signUp() }
                )
                HStack {
                    Text("Already have an account?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button(action: { onSwitchToSignIn() }) { Text("Sign in").underline() }
                        .buttonStyle(.plain)
                        .tint(.primary)
                }
            }
            Spacer()
            Group {
                PrimaryButton(title: "Create account", isLoading: isLoading, isDisabled: !canSubmit) {
                    signUp()
                }
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            }
        }
        .sheet(isPresented: $isPushingVerify) { VerifyOtpView(email: email, flow: .signUp, password: password) }
    }

    private var header: some View {
        VStack(alignment: .center, spacing: 16) {
            VStack(alignment: .center, spacing: 4) {
                Text("Create your account")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color(.label))
                Text("Join Sawaed with your email and password")
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

    private var confirmPasswordError: LocalizedStringKey? {
        if confirmPassword.isEmpty { return nil }
        return confirmPassword == password ? nil : "Passwords do not match"
    }

    private var canSubmit: Bool {
        isValidEmail(email) && password.count >= 6 && confirmPassword == password
    }

    private func signUp() {
        guard canSubmit else { return }
        isLoading = true
        errorMessage = nil
        Task {
            do {
                try await container.auth.signUp(email: email, password: password)
                try await container.auth.requestOtp(email: email)
                isPushingVerify = true
            } catch {
                if case let AuthService.AuthError.server(code, _) = error {
                    if code == "email_already_exists" {
                        errorMessage = "Email already exists"
                    } else {
                        errorMessage = "Failed to sign up"
                    }
                } else {
                    errorMessage = "Failed to sign up"
                }
            }
            isLoading = false
        }
    }

    private func isValidEmail(_ value: String) -> Bool {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return value.range(of: pattern, options: .regularExpression) != nil
    }
}
