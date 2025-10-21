import Foundation

struct ChatSendResponse: Codable, Sendable {
    let sessionId: String
    let conversationId: String?
}
