import Foundation
import SwiftUI
import Combine

enum OnboardingStep: Int, CaseIterable {
    case profile = 0
    case skills = 1
    case interests = 2
    case location = 3
}

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .profile
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Simple fields for demo
    @Published var name: String = ""
    @Published var selectedSkills: [String] = []
    @Published var selectedInterests: [String] = []
    @Published var regions: [RegionDTO] = []
    @Published var cities: [CityDTO] = []
    @Published var selectedRegionId: String?
    @Published var selectedCityId: String?

    func loadRegions(container: AppContainer) {
        isLoading = true
        Task { [weak self] in
            guard let self else { return }
            do {
                self.regions = try await container.onboarding.regions()
            } catch {
                self.errorMessage = "Failed to load regions"
            }
            self.isLoading = false
        }
    }

    func loadCities(container: AppContainer) {
        guard let regionId = selectedRegionId else { return }
        isLoading = true
        Task { [weak self] in
            guard let self else { return }
            do {
                self.cities = try await container.onboarding.cities(regionId: regionId)
            } catch {
                self.errorMessage = "Failed to load cities"
            }
            self.isLoading = false
        }
    }

    func saveDraftDetails(container: AppContainer) {
        struct Payload: Codable { let name: String }
        isLoading = true
        Task { [weak self] in
            guard let self else { return }
            do {
                let body = try JSONEncoder().encode(Payload(name: self.name))
                try await container.onboarding.saveDraftDetails(payload: body)
                self.advance()
            } catch {
                self.errorMessage = "Failed to save details"
            }
            self.isLoading = false
        }
    }

    func saveDraftTaxonomies(container: AppContainer) {
        struct Payload: Codable { let skills: [String]; let interests: [String] }
        isLoading = true
        Task { [weak self] in
            guard let self else { return }
            do {
                let body = try JSONEncoder().encode(Payload(skills: self.selectedSkills, interests: self.selectedInterests))
                try await container.onboarding.saveDraftTaxonomies(payload: body)
                self.advance()
            } catch {
                self.errorMessage = "Failed to save selections"
            }
            self.isLoading = false
        }
    }

    func complete(container: AppContainer, appVM: AppViewModel) {
        isLoading = true
        Task { [weak self] in
            guard let self else { return }
            do {
                try await container.onboarding.complete()
                appVM.authState = .signedIn
            } catch {
                self.errorMessage = "Failed to complete onboarding"
            }
            self.isLoading = false
        }
    }

    func advance() {
        if let next = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            currentStep = next
        }
    }

    func back() {
        if let prev = OnboardingStep(rawValue: currentStep.rawValue - 1) {
            currentStep = prev
        }
    }
}
