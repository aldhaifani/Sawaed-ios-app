import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var container: AppContainer
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
    }
}
