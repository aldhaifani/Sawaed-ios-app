import Foundation
import SwiftUI
import Combine

@MainActor
final class AppViewModel: ObservableObject {
    enum AuthState {
        case signedOut
        case onboarding
        case signedIn
    }

    @Published var authState: AuthState = .signedOut
    @Published var locale: String = Locale.current.language.languageCode?.identifier ?? "en"
}
