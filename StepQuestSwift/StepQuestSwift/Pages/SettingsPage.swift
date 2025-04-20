//
//  SettingsPage.swift
//  StepQuestSwift
//
//  Created by Adam Horvitz on 3/7/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct SettingsPage: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userDataManager: UserDataManager
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var weeklyGoal: Int = 20000

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile")) {
                    TextField("Name", text: $name)
                }
                
                Section(header: Text("Weekly Step Goal")) {
                    Stepper("Goal: \(weeklyGoal) steps", value: $weeklyGoal, in: 1000...150000, step: 1000)
                }
                
                Section {
                    Button("Save Changes") {
                        userDataManager.updateUserData(
                            name: name,
                            weeklyGoal: weeklyGoal
                        )

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            userDataManager.fetchUserData()
                            dismiss()
                        }
                    }
                    .foregroundColor(.blue)
                }
                
                Section {
                    Button("Sign Out") {
                        signOut()
                    }
                    .foregroundColor(.red)
                }

            }
            .navigationTitle("Settings")
            .onAppear {
                name = userDataManager.name
                weeklyGoal = userDataManager.weeklyGoal
            }
        }
    }
    func signOut() {
            do {
                try Auth.auth().signOut()
                authManager.isLoggedIn = false
            } catch {
                print("Sign out failed:", error.localizedDescription)
            }
        }
}

#Preview {
    SettingsPage()
}

