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
    @StateObject var healthManager = HealthManager()
    @StateObject var userDataManager = UserDataManager()
    
    var body: some Scene {
        WindowGroup {
            ContentViewSwitcher()
                .environmentObject(authManager)
                .environmentObject(healthManager)
                .environmentObject(userDataManager)
        }
    }
}

struct ContentViewSwitcher: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        if authManager.isLoggedIn {
            ContentView()
            
        } else {
            LoginPage()
        }
    }
}

