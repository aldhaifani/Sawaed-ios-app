import SwiftUI

struct OnboardingStepperView: View {
    @StateObject private var vm = OnboardingViewModel()
    @EnvironmentObject var container: AppContainer
    @EnvironmentObject var appVM: AppViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Onboarding")
                .font(.headline)

            switch vm.currentStep {
            case .profile:
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                    TextField("Your name", text: $vm.name)
                        .textFieldStyle(.roundedBorder)
                    Button(vm.isLoading ? "…" : "Next") { vm.saveDraftDetails(container: container) }
                        .disabled(vm.isLoading || vm.name.isEmpty)
                }
            case .skills:
                VStack(alignment: .leading, spacing: 8) {
                    Text("Skills (comma separated IDs)")
                    TextField("1,2,3", text: Binding(
                        get: { vm.selectedSkills.joined(separator: ",") },
                        set: { vm.selectedSkills = $0.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) } }
                    ))
                    .textFieldStyle(.roundedBorder)
                    Button(vm.isLoading ? "…" : "Next") { vm.saveDraftTaxonomies(container: container) }
                        .disabled(vm.isLoading)
                }
            case .interests:
                VStack(alignment: .leading, spacing: 8) {
                    Text("Interests (comma separated IDs)")
                    TextField("a,b,c", text: Binding(
                        get: { vm.selectedInterests.joined(separator: ",") },
                        set: { vm.selectedInterests = $0.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) } }
                    ))
                    .textFieldStyle(.roundedBorder)
                    Button("Next") { vm.advance() }
                }
            case .location:
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Button("Load Regions") { vm.loadRegions(container: container) }
                        if vm.isLoading { ProgressView() }
                    }
                    Picker("Region", selection: $vm.selectedRegionId) {
                        ForEach(vm.regions, id: \.id) { r in Text(r.name).tag(Optional(r.id)) }
                    }
                    Button("Load Cities") { vm.loadCities(container: container) }
                    Picker("City", selection: $vm.selectedCityId) {
                        ForEach(vm.cities, id: \.id) { c in Text(c.name).tag(Optional(c.id)) }
                    }
                    Button(vm.isLoading ? "…" : "Complete") { vm.complete(container: container, appVM: appVM) }
                        .disabled(vm.isLoading || vm.selectedCityId == nil)
                }
            }

            if let error = vm.errorMessage { Text(error).foregroundColor(.red).font(.footnote) }
        }
        .padding()
        .navigationTitle("Onboarding")
    }
}
