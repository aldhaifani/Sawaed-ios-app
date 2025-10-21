import Foundation

struct HTTPRequest: Sendable {
    let method: String
    let path: String
    let query: [String: String]?
    let headers: [String: String]
    let body: Data?

    init(method: String, path: String, query: [String: String]? = nil, headers: [String: String] = [:], body: Data? = nil) {
        self.method = method
        self.path = path
        self.query = query
        self.headers = headers
        self.body = body
    }
}

struct HTTPResponse: Sendable {
    let status: Int
    let data: Data
    let headers: [AnyHashable: Any]
}

protocol TokenProvider: AnyObject {
    func accessToken() -> String?
    func refresh() async -> Bool
}

final class HTTPClient {
    let baseURL: URL
    let tokenProvider: TokenProvider?
    let urlSession: URLSession

    init(baseURL: URL, tokenProvider: TokenProvider?, urlSession: URLSession = .shared) {
        self.baseURL = baseURL
        self.tokenProvider = tokenProvider
        self.urlSession = urlSession
    }

    func send(_ req: HTTPRequest) async throws -> HTTPResponse {
        var url = baseURL.appendingPathComponent(req.path)
        if let query = req.query, var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
            url = components.url ?? url
        }
        var request = URLRequest(url: url)
        request.httpMethod = req.method
        var headers = req.headers
        if let token = tokenProvider?.accessToken(), headers["Authorization"] == nil {
            headers["Authorization"] = "Bearer \(token)"
        }
        if headers["Accept-Language"] == nil {
            headers["Accept-Language"] = Locale.preferredLanguages.first ?? "en"
        }
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        request.httpBody = req.body

        let (data, response) = try await urlSession.data(for: request)
        let http = response as? HTTPURLResponse
        let status = http?.statusCode ?? 0

        if status == 401, let tokenProvider {
            let refreshed = await tokenProvider.refresh()
            if refreshed {
                return try await send(req)
            }
        }

        return HTTPResponse(status: status, data: data, headers: http?.allHeaderFields ?? [:])
    }
}
