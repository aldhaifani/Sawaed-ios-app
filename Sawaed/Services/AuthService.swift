import Foundation

final class AuthService {
    private let http: HTTPClient
    private let keychain: KeychainStore

    init(http: HTTPClient, keychain: KeychainStore) {
        self.http = http
        self.keychain = keychain
    }

    func requestOtp(email: String) async throws {
        let body = try JSONEncoder().encode(["email": email])
        let req = HTTPRequest(method: "POST", path: Endpoints.authRequestOtp(), headers: ["Content-Type": "application/json"], body: body)
        _ = try await http.send(req)
    }

    func verifyOtp(email: String, code: String) async throws {
        let body = try JSONEncoder().encode(["email": email, "code": code])
        let req = HTTPRequest(method: "POST", path: Endpoints.authVerifyOtp(), headers: ["Content-Type": "application/json"], body: body)
        let resp = try await http.send(req)
        let tokens = try JSONDecoder().decode(AuthTokens.self, from: resp.data)
        keychain.setTokens(access: tokens.token, refresh: tokens.refreshToken)
    }

    func refresh() async throws -> Bool {
        guard let refresh = keychain.refreshToken() else { return false }
        let body = try JSONEncoder().encode(["refreshToken": refresh])
        let req = HTTPRequest(method: "POST", path: Endpoints.authRefresh(), headers: ["Content-Type": "application/json"], body: body)
        let resp = try await http.send(req)
        if (200..<300).contains(resp.status) {
            let tokens = try JSONDecoder().decode(AuthTokens.self, from: resp.data)
            keychain.setTokens(access: tokens.token, refresh: tokens.refreshToken)
            return true
        }
        return false
    }

    func signout() async throws {
        let req = HTTPRequest(method: "POST", path: Endpoints.authSignout(), headers: ["Content-Type": "application/json"], body: Data())
        _ = try await http.send(req)
    }
}
