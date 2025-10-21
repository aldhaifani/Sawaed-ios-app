import SwiftUI

struct OpportunityDetailView: View {
    let opportunityId: String
    private let http: HTTPClient
    @StateObject private var vm: OpportunityDetailViewModel

    init(http: HTTPClient, opportunityId: String) {
        self.http = http
        self.opportunityId = opportunityId
        _vm = StateObject(wrappedValue: OpportunityDetailViewModel(http: http, id: opportunityId))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let d = vm.detail {
                Text(d.title).font(.headline)
                if let desc = d.description { Text(desc) }
                HStack { if let r = d.region { Text(r) }; if let c = d.city { Text(c) } }
                if let s = d.startDate { Text("Start: \(s)") }
                if let e = d.endDate { Text("End: \(e)") }
            }
            if vm.isLoading { ProgressView() }
            if let error = vm.errorMessage { Text(error).foregroundColor(.red) }
        }
        .padding()
        .navigationTitle("Opportunity")
        .onAppear { vm.fetch() }
    }
}
