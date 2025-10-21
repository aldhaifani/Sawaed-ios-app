import SwiftUI

struct OpportunitiesListView: View {
    private let http: HTTPClient
    @StateObject private var vm: OpportunitiesViewModel

    init(http: HTTPClient) {
        self.http = http
        _vm = StateObject(wrappedValue: OpportunitiesViewModel(http: http))
    }

    var body: some View {
        List(vm.items) { item in
            NavigationLink(item.title) {
                OpportunityDetailView(http: http, opportunityId: item.id)
            }
        }
        .overlay {
            if vm.isLoading { ProgressView() }
            if let error = vm.errorMessage { Text(error).foregroundColor(.red) }
        }
        .navigationTitle("Opportunities")
        .onAppear { vm.fetch() }
    }
}
