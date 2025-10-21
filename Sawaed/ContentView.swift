//
//  ContentView.swift
//  Sawaed
//
//  Created by Tareq Aldhaifani on 20/10/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appVM: AppViewModel

    var body: some View {
        VStack {
            Text("Sawaed iOS")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
