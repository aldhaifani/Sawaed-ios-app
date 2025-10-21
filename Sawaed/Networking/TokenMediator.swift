import Foundation

final class TokenMediator: TokenProvider {
    private let keychain: KeychainStore
    private let baseURL: URL
    private let urlSession: URLSession

    init(keychain: KeychainStore, baseURL: URL, urlSession: URLSession = .shared) {
        self.keychain = keychain
        self.baseURL = baseURL
        self.urlSession = urlSession
    }

    func accessToken() -> String? { keychain.accessToken() }

    func refresh() async -> Bool {
        guard let refresh = keychain.refreshToken() else { return false }
        var req = URLRequest(url: baseURL.appendingPathComponent("/api/mobile/auth/refresh"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONEncoder().encode(["refreshToken": refresh])
        do {
            let (data, response) = try await urlSession.data(for: req)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else { return false }
            let tokens = try JSONDecoder().decode(AuthTokens.self, from: data)
            keychain.setTokens(access: tokens.token, refresh: tokens.refreshToken)
            return true
        } catch {
            return false
        }
    }
}
