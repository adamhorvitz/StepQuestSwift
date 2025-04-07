//
//  ContentView.swift
//  StepQuestSwift
//
//  Created by Adam Horvitz on 3/7/25.
//

import SwiftUI
//add log out button at one point maybe in settings page
//authManager.isLoggedIn = false

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject var healthManager = HealthManager()

    var body: some View {
        TabView {
            UserPage()
                .tabItem {
                    Label("User", systemImage: "person.crop.circle")
                }
                .environmentObject(healthManager)
            RankingPage()
                .tabItem {
                    Label("Ranking", systemImage: "rosette")
                }
            FriendsPage()
                .tabItem {
                    Label("Friends", systemImage: "person.2")
                }
//            SettingsPage()
//                .tabItem {
//                    Label("Settings", systemImage: "gear")
//                }
        }
        
        
    }
}

#Preview {
    ContentView()
}
