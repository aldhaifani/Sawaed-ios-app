import Foundation
import SwiftUI
import Combine

@MainActor
final class OpportunitiesViewModel: ObservableObject {
    @Published var items: [EventListItemDTO] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    private let http: HTTPClient

    init(http: HTTPClient) {
        self.http = http
    }

    func fetch() {
        isLoading = true
        errorMessage = nil
        Task { [weak self] in
            guard let self else { return }
            do {
                let req = HTTPRequest(method: "GET", path: Endpoints.events())
                let resp = try await http.send(req)
                let list = try JSONDecoder().decode([EventListItemDTO].self, from: resp.data)
                self.items = list
            } catch {
                self.errorMessage = "Failed to load opportunities"
            }
            self.isLoading = false
        }
    }
}
