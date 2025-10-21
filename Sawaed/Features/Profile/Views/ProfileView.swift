import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var container: AppContainer
    @StateObject private var vm = ProfileViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let p = vm.profile {
                if let name = p.name { Text(name).font(.title3) }
                if let email = p.email { Text(email).font(.subheadline) }
                if let phone = p.phone { Text(phone) }
                if let gender = p.gender { Text(gender) }
            }
            if vm.isLoading { ProgressView() }
            if let error = vm.errorMessage { Text(error).foregroundColor(.red) }
        }
        .padding()
        .navigationTitle("Profile")
        .onAppear { vm.fetch(container: container) }
    }
}
