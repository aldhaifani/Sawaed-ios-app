import SwiftUI

struct VerifyOtpView: View {
    let email: String
    @State private var code: String = ""
    @State private var isLoading: Bool = false
    @State private var isResending: Bool = false
    @State private var errorMessage: LocalizedStringKey?
    @EnvironmentObject var appVM: AppViewModel
    @EnvironmentObject var container: AppContainer

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
                                Text(isResending ? LocalizedStringKey("Sending…") : LocalizedStringKey("Resend code"))
                            }
                            .buttonStyle(.plain)
                            .tint(.secondary)
                            .disabled(isResending)
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
    }

    private func verify() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                try await container.auth.verifyOtp(email: email, code: code)
                let status = try await container.onboarding.status()
                if status.status.uppercased() == "COMPLETED" {
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
            } catch {
                errorMessage = "Failed to resend code"
            }
            isResending = false
        }
    }
    
    private var canSubmit: Bool {
        code.trimmingCharacters(in: .whitespaces).count >= 4
    }

    private var codeError: LocalizedStringKey? {
        if code.isEmpty { return nil }
        return canSubmit ? nil : "Code should be at least 4 digits"
    }
}

