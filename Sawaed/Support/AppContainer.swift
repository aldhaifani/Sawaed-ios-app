import Foundation
import SwiftUI
import Combine

final class AppContainer: ObservableObject {
    let keychain: KeychainStore
    let defaults: UserDefaultsStore
    let http: HTTPClient
    let auth: AuthService
    let onboarding: OnboardingService
    let profile: ProfileService

    init(keychain: KeychainStore, defaults: UserDefaultsStore, http: HTTPClient, auth: AuthService, onboarding: OnboardingService, profile: ProfileService) {
        self.keychain = keychain
        self.defaults = defaults
        self.http = http
        self.auth = auth
        self.onboarding = onboarding
        self.profile = profile
    }
}
