//
//  SawaedApp.swift
//  Sawaed
//
//  Created by Tareq Aldhaifani on 20/10/2025.
//

import SwiftUI
import Foundation

@main
struct SawaedApp: App {
    private let baseURL = URL(string: "https://sawaed.tareq.pro")!
    private let keychain = KeychainStore()
    private lazy var tokenMediator = TokenMediator(keychain: keychain, baseURL: baseURL)
    private lazy var httpClient = HTTPClient(baseURL: baseURL, tokenProvider: tokenMediator)
    private lazy var authService = AuthService(http: httpClient, keychain: keychain)
    @StateObject private var appViewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
        }
    }
}
