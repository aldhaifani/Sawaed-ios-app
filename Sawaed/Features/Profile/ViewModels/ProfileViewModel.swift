import Foundation
import SwiftUI
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile: ProfileCompositeDTO?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func fetch(container: AppContainer) {
        isLoading = true
        errorMessage = nil
        Task { [weak self] in
            guard let self else { return }
            do {
                let dto = try await container.profile.me()
                self.profile = dto
            } catch {
                self.errorMessage = "Failed to load profile"
            }
            self.isLoading = false
        }
    }
}
