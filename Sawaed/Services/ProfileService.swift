import Foundation

struct ProfileCompositeDTO: Codable, Sendable {
    let id: String
    let name: String?
    let email: String?
    let phone: String?
    let gender: String?
}

final class ProfileService {
    private let http: HTTPClient
    init(http: HTTPClient) { self.http = http }

    func me() async throws -> ProfileCompositeDTO {
        let req = HTTPRequest(method: "GET", path: Endpoints.profileMe())
        let resp = try await http.send(req)
        return try JSONDecoder().decode(ProfileCompositeDTO.self, from: resp.data)
    }
}
