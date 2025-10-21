import Foundation

struct RegionDTO: Codable, Sendable { let id: String; let name: String }
struct CityDTO: Codable, Sendable { let id: String; let name: String }
struct OnboardingStatusDTO: Codable, Sendable { let status: String }

final class OnboardingService {
    private let http: HTTPClient

    init(http: HTTPClient) { self.http = http }

    func status() async throws -> OnboardingStatusDTO {
        let req = HTTPRequest(method: "GET", path: Endpoints.onboardingStatus())
        let resp = try await http.send(req)
        return try JSONDecoder().decode(OnboardingStatusDTO.self, from: resp.data)
    }

    func regions() async throws -> [RegionDTO] {
        let req = HTTPRequest(method: "GET", path: Endpoints.locationsRegions())
        let resp = try await http.send(req)
        return try JSONDecoder().decode([RegionDTO].self, from: resp.data)
    }

    func cities(regionId: String) async throws -> [CityDTO] {
        let req = HTTPRequest(method: "GET", path: Endpoints.locationsCities(), query: ["regionId": regionId])
        let resp = try await http.send(req)
        return try JSONDecoder().decode([CityDTO].self, from: resp.data)
    }

    func saveDraftDetails(payload: Data) async throws {
        let req = HTTPRequest(method: "POST", path: Endpoints.onboardingSaveDraftDetails(), headers: ["Content-Type": "application/json"], body: payload)
        _ = try await http.send(req)
    }

    func saveDraftTaxonomies(payload: Data) async throws {
        let req = HTTPRequest(method: "POST", path: Endpoints.onboardingSaveDraftTaxonomies(), headers: ["Content-Type": "application/json"], body: payload)
        _ = try await http.send(req)
    }

    func complete() async throws {
        let req = HTTPRequest(method: "POST", path: Endpoints.onboardingComplete(), headers: ["Content-Type": "application/json"], body: Data())
        _ = try await http.send(req)
    }
}
