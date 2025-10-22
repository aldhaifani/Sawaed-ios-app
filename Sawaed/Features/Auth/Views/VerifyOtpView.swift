import SwiftUI
import Combine

enum AuthFlow {
    case signIn
    case signUp
}

struct VerifyOtpView: View {
    let email: String
    let flow: AuthFlow
    let password: String?
    @State private var code: String = ""
    @State private var isLoading: Bool = false
    @State private var isResending: Bool = false
    @State private var cooldownRemaining: Int = 0
    @State private var errorMessage: LocalizedStringKey?
    @EnvironmentObject var appVM: AppViewModel
    @EnvironmentObject var container: AppContainer
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            AppGridBackgroundView().ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 12)
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Verify code")
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(Color(.label))
                            Text("Enter the code we sent to \(email)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        AppTextField(
                            label: "Code",
                            placeholder: "000000",
                            text: $code,
                            isSecure: false,
                            keyboardType: .numberPad,
                            contentType: .oneTimeCode,
                            submitLabel: .go,
                            size: .large,
                            leadingSystemImage: "number",
                            error: codeError,
                            onSubmit: { verify() }
                        )
                        HStack {
                            Button(action: { resend() }) {
                                if cooldownRemaining > 0 {
                                    Text(String(format: NSLocalizedString("Resend in %@", comment: "resend countdown"), formatTime(cooldownRemaining)))
                                } else {
                                    Text(isResending ? LocalizedStringKey("Sending…") : LocalizedStringKey("Resend code"))
                                }
                            }
                            .buttonStyle(.plain)
                            .tint(.secondary)
                            .disabled(isResending || cooldownRemaining > 0)
                            Spacer()
                        }
                        PrimaryButton(title: "Verify", isLoading: isLoading, isDisabled: !canSubmit) {
                            verify()
                        }
                        if let errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
                    }
                    .cardContainer()
                    Spacer(minLength: 24)
                }
            }
        }
        .onReceive(timer) { _ in
            if cooldownRemaining > 0 { cooldownRemaining -= 1 }
        }
    }

    private func verify() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                try await container.auth.verifyOtp(email: email, code: code)
                let status = try await container.onboarding.status()
                if status.completed {
                    appVM.authState = .signedIn
                } else {
                    appVM.authState = .onboarding
                }
            } catch {
                errorMessage = "Invalid code"
            }
            isLoading = false
        }
    }

    private func resend() {
        isResending = true
        errorMessage = nil
        Task {
            do {
                try await container.auth.requestOtp(email: email)
                cooldownRemaining = 120
            } catch {
                errorMessage = "Failed to resend code"
            }
            isResending = false
        }
    }
    
    private var canSubmit: Bool {
        let trimmed = code.trimmingCharacters(in: .whitespaces)
        return trimmed.range(of: "^\\d{6}$", options: .regularExpression) != nil
    }

    private var codeError: LocalizedStringKey? {
        if code.isEmpty { return nil }
        return canSubmit ? nil : "Code must be 6 digits"
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

