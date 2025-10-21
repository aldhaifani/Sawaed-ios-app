import Foundation
import SwiftUI
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var input: String = ""
    @Published var messages: [String] = []
    @Published var isSending: Bool = false
    private var sessionId: String?
    private let polling: ChatPollingService
    private let http: HTTPClient

    init(http: HTTPClient) {
        self.http = http
        self.polling = ChatPollingService(http: http)
    }

    func send() {
        guard !input.isEmpty else { return }
        let text = input
        input = ""
        messages.append("You: \(text)")
        isSending = true
        Task { [weak self] in
            guard let self else { return }
            do {
                let body = try JSONEncoder().encode(["message": text])
                let req = HTTPRequest(method: "POST", path: Endpoints.chatSend(), headers: ["Content-Type": "application/json"], body: body)
                let resp = try await self.http.send(req)
                let data = try JSONDecoder().decode(ChatSendResponse.self, from: resp.data)
                self.sessionId = data.sessionId
                self.startPolling()
            } catch {
                self.messages.append("Error: failed to send")
            }
            self.isSending = false
        }
    }

    private func startPolling() {
        guard let sessionId else { return }
        polling.start(sessionId: sessionId, onUpdate: { [weak self] data in
            guard let self else { return }
            if let text = String(data: data, encoding: .utf8) {
                Task { @MainActor in
                    self.messages.append("Bot: \(text)")
                }
            }
        })
    }

    func stop() {
        polling.stop()
    }
}
