//
//  StepQuestSwiftApp.swift
//  StepQuestSwift
//
//  Created by Adam Horvitz on 3/7/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
}

@main
struct StepQuestSwiftApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    @StateObject var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            if authManager.isLoggedIn {
                ContentView()
            } else {
                LoginPage()
            }
        }
        .environmentObject(authManager)
    }
}
