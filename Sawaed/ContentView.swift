//
//  ContentView.swift
//  Sawaed
//
//  Created by Tareq Aldhaifani on 20/10/2025.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @EnvironmentObject var appVM: AppViewModel
    @EnvironmentObject var appContainer: AppContainer
    @State private var didBootstrap: Bool = false

    var body: some View {
        NavigationStack {
            Group {
                switch appVM.authState {
                case .signedOut:
                    AuthTabsView()
                case .onboarding:
                    OnboardingStepperView()
                case .signedIn:
                    MainTabView()
                }
            }
        }
        .environment(\.layoutDirection, appVM.locale.starts(with: "ar") ? .rightToLeft : .leftToRight)
        .environment(\.locale, Locale(identifier: appVM.locale))
        .onAppear { bootstrapAuthStateIfNeeded() }
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
    return ContentView()
        .environmentObject(AppViewModel())
        .environmentObject(container)
}

private extension ContentView {
    func bootstrapAuthStateIfNeeded() {
        guard !didBootstrap else { return }
        didBootstrap = true
        if appContainer.keychain.accessToken() != nil {
            Task { @MainActor in
                do {
                    let status = try await appContainer.onboarding.status()
                    if status.completed {
                        appVM.authState = .signedIn
                    } else {
                        appVM.authState = .onboarding
                    }
                } catch {
                    appVM.authState = .signedOut
                }
            }
        } else {
            appVM.authState = .signedOut
        }
    }
}

