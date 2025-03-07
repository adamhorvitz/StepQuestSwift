//
//  ContentView.swift
//  StepQuestSwift
//
//  Created by Adam Horvitz on 3/7/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            UserPage()
                .tabItem {
                    Label("User", systemImage: "person.crop.circle")
                }
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
