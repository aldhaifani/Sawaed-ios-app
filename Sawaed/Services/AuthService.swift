import Foundation

final class AuthService {
    private let http: HTTPClient
    private let keychain: KeychainStore

    init(http: HTTPClient, keychain: KeychainStore) {
        self.http = http
        self.keychain = keychain
    }

    struct ErrorEnvelope: Codable { struct Err: Codable { let code: String; let message: String }; let error: Err }
    enum AuthError: Error { case server(code: String, message: String) }
    private func throwIfError(_ resp: HTTPResponse) throws {
        guard (200..<300).contains(resp.status) else {
            if let env = try? JSONDecoder().decode(ErrorEnvelope.self, from: resp.data) {
                throw AuthError.server(code: env.error.code, message: env.error.message)
            }
            throw AuthError.server(code: "unknown_error", message: "Request failed")
        }
    }

    func requestOtp(email: String) async throws {
        let body = try JSONEncoder().encode(["email": email])
        let req = HTTPRequest(method: "POST", path: Endpoints.authRequestOtp(), headers: ["Content-Type": "application/json"], body: body)
        let resp = try await http.send(req)
        try throwIfError(resp)
    }

    func verifyOtp(email: String, code: String) async throws {
        let body = try JSONEncoder().encode(["email": email, "code": code])
        let req = HTTPRequest(method: "POST", path: Endpoints.authVerifyOtp(), headers: ["Content-Type": "application/json"], body: body)
        let resp = try await http.send(req)
        try throwIfError(resp)
        let tokens = try JSONDecoder().decode(AuthTokens.self, from: resp.data)
        keychain.setTokens(access: tokens.token, refresh: tokens.refreshToken)
    }

    func signIn(email: String, password: String) async throws {
        let body = try JSONEncoder().encode(["email": email, "password": password])
        let req = HTTPRequest(method: "POST", path: Endpoints.authSignin(), headers: ["Content-Type": "application/json"], body: body)
        let resp = try await http.send(req)
        try throwIfError(resp)
        let tokens = try JSONDecoder().decode(AuthTokens.self, from: resp.data)
        keychain.setTokens(access: tokens.token, refresh: tokens.refreshToken)
    }

    func signUp(email: String, password: String) async throws {
        let body = try JSONEncoder().encode(["email": email, "password": password])
        let req = HTTPRequest(method: "POST", path: Endpoints.authSignup(), headers: ["Content-Type": "application/json"], body: body)
        let resp = try await http.send(req)
        try throwIfError(resp)
        _ = resp
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
