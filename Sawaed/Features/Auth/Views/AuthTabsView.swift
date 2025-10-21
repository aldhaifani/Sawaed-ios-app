import SwiftUI

enum AuthTab: Int { case signIn = 0, signUp = 1 }

struct AuthTabsView: View {
    @EnvironmentObject var appVM: AppViewModel
    @State private var selection: AuthTab = .signIn

    var body: some View {
        ZStack {
            AppGridBackgroundView().ignoresSafeArea()
            VStack(spacing: 16) {
                header
                TabView(selection: $selection) {
                    SignInView(onSwitchToSignUp: switchToSignUp)
                        .tag(AuthTab.signIn)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    SignUpView(onSwitchToSignIn: switchToSignIn)
                        .tag(AuthTab.signUp)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .accessibilityHidden(true)
            Spacer()
            languageToggle
        }
        .padding(.horizontal, Theme.cardHorizontalPadding)
        .padding(.top, 8)
    }

    private var languageToggle: some View {
        HStack(spacing: 8) {
            Button(action: { setLocale("en") }) {
                Text("English")
                    .font(.subheadline.weight(.semibold))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        Group {
                            if appVM.locale.starts(with: "en") {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color(.systemIndigo))
                            } else {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(Color(.separator), lineWidth: 1)
                            }
                        }
                    )
                    .foregroundStyle(appVM.locale.starts(with: "en") ? Color.white : Color.primary)
            }
            .buttonStyle(.plain)
            Button(action: { setLocale("ar") }) {
                Text("العربية")
                    .font(.subheadline.weight(.semibold))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        Group {
                            if appVM.locale.starts(with: "ar") {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color(.systemIndigo))
                            } else {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(Color(.separator), lineWidth: 1)
                            }
                        }
                    )
                    .foregroundStyle(appVM.locale.starts(with: "ar") ? Color.white : Color.primary)
            }
            .buttonStyle(.plain)
        }
    }

    private func setLocale(_ code: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            appVM.locale = code
        }
    }

    private func switchToSignUp() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) { selection = .signUp }
    }

    private func switchToSignIn() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) { selection = .signIn }
    }
}
