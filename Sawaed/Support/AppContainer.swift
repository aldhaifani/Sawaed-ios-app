import Foundation
import SwiftUI
import Combine

final class AppContainer: ObservableObject {
    let keychain: KeychainStore
    let defaults: UserDefaultsStore
    let http: HTTPClient
    let auth: AuthService

    init(keychain: KeychainStore, defaults: UserDefaultsStore, http: HTTPClient, auth: AuthService) {
        self.keychain = keychain
        self.defaults = defaults
        self.http = http
        self.auth = auth
    }
}
