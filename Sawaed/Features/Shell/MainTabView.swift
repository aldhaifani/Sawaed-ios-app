import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var container: AppContainer
    @EnvironmentObject var appVM: AppViewModel
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }
            LearningView()
                .tabItem {
                    Label("Learning", systemImage: "book")
                }
            ChatView(viewModel: ChatViewModel(http: container.http))
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.text.bubble.right")
                }
            OpportunitiesListView(http: container.http)
                .tabItem {
                    Label("Opportunities", systemImage: "list.bullet.rectangle")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Sign out") { signOut() }
            }
        }
    }
}

private extension MainTabView {
    func signOut() {
        Task { @MainActor in
            do {
                try await container.auth.signout()
            } catch {
                // ignore server errors on sign out
            }
            container.keychain.clearTokens()
            appVM.authState = .signedOut
        }
    }
}
