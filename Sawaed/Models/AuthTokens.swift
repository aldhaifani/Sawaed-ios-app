import Foundation

public struct AuthTokens: Codable, Sendable {
    public let token: String
    public let refreshToken: String
}
