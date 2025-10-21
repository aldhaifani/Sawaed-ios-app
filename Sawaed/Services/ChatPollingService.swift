import Foundation

final class ChatPollingService {
    private let http: HTTPClient
    private var task: Task<Void, Never>?
    private var lastETag: String?

    init(http: HTTPClient) {
        self.http = http
    }

    /// Starts structured-concurrency polling. Call `stop()` to cancel.
    /// - Parameters:
    ///   - sessionId: Chat session identifier.
    ///   - intervalMs: Polling interval in milliseconds (default 400ms).
    ///   - onUpdate: Callback invoked when a 200 response body is received.
    func start(sessionId: String, intervalMs: Int = 400, onUpdate: @escaping (Data) -> Void) {
        stop()
        task = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                await self.tick(sessionId: sessionId, onUpdate: onUpdate)
                // Sleep between polls; tolerate cancellation.
                try? await Task.sleep(nanoseconds: UInt64(intervalMs) * 1_000_000)
            }
        }
    }

    /// Cancels the polling task.
    func stop() {
        task?.cancel()
        task = nil
    }

    private func tick(sessionId: String, onUpdate: @escaping (Data) -> Void) async {
        var headers: [String: String] = [:]
        if let etag = lastETag { headers["If-None-Match"] = etag }
        let req = HTTPRequest(method: "GET", path: Endpoints.chatStatus(), query: ["sessionId": sessionId], headers: headers)
        do {
            let resp = try await http.send(req)
            if let etag = (resp.headers["Etag"] as? String) ?? (resp.headers["ETag"] as? String) {
                lastETag = etag
            }
            if resp.status == 200 { onUpdate(resp.data) }
        } catch {
            // Optional: log or send breadcrumbs
        }
    }
}
