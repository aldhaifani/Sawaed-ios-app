//
//  SawaedApp.swift
//  Sawaed
//
//  Created by Tareq Aldhaifani on 20/10/2025.
//

import SwiftUI
import Foundation

@main
struct SawaedApp: App {
    private let baseURL = URL(string: "https://sawaed.tareq.pro")!
    @StateObject private var appContainer: AppContainer
    @StateObject private var appViewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
                .environmentObject(appContainer)
        }
    }

    init() {
        let keychain = KeychainStore()
        let defaults = UserDefaultsStore()
        let tokenMediator = TokenMediator(keychain: keychain, baseURL: baseURL)
        let httpClient = HTTPClient(baseURL: baseURL, tokenProvider: tokenMediator)
        let authService = AuthService(http: httpClient, keychain: keychain)
        let onboardingService = OnboardingService(http: httpClient)
        let profileService = ProfileService(http: httpClient)
        let container = AppContainer(keychain: keychain, defaults: defaults, http: httpClient, auth: authService, onboarding: onboardingService, profile: profileService)
        _appContainer = StateObject(wrappedValue: container)
    }
}
