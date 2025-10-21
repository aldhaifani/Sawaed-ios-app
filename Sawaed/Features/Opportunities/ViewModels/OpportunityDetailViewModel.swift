import Foundation
import SwiftUI
import Combine

@MainActor
final class OpportunityDetailViewModel: ObservableObject {
    @Published var detail: EventDetailDTO?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    private let http: HTTPClient
    private let id: String

    init(http: HTTPClient, id: String) {
        self.http = http
        self.id = id
    }

    func fetch() {
        isLoading = true
        errorMessage = nil
        Task { [weak self] in
            guard let self else { return }
            do {
                let req = HTTPRequest(method: "GET", path: Endpoints.event(id: id))
                let resp = try await http.send(req)
                let dto = try JSONDecoder().decode(EventDetailDTO.self, from: resp.data)
                self.detail = dto
            } catch {
                self.errorMessage = "Failed to load details"
            }
            self.isLoading = false
        }
    }
}
