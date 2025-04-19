//
//  UserDataManager.swift
//  StepQuestSwift
//
//  Created by Shirley Mazariegos on 4/18/25.
//
import Foundation
import SwiftUI
import Firebase
import FirebaseAuth

//use this for when user edit profile
//when streak/rank changes like after a step mileston
// updateing one thing: userDataManager.updateUserData(rank: "Gold")
// updating more than one thing: userDataManager.updateUserDate(name: "Shirley", streak: 8)
//go to setting to see ex view to display/change profile stuff
class UserDataManager: ObservableObject {
    @Published var name: String = ""
    @Published var rank: String = ""
    @Published var streak: Int = 0
    @Published var weeklyGoal: Int = 20000

    func fetchUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("users").document(uid).getDocument { document, error in
            guard let document = document, document.exists,
                  let data = document.data() else {
                print("Failed to fetch user data")
                return
            }

            DispatchQueue.main.async {
                self.name = data["name"] as? String ?? ""
                self.rank = data["rank"] as? String ?? "Bronze"
                self.streak = data["streak"] as? Int ?? 0
                self.weeklyGoal = data["weeklyGoal"] as? Int ?? 20000

                // PATCH missing fields back to Firestore
                var updates: [String: Any] = [:]
                if data["rank"] == nil { updates["rank"] = "Bronze" }
                if data["streak"] == nil { updates["streak"] = 0 }
                if data["weeklyGoal"] == nil { updates["weeklyGoal"] = 20000 }

                if !updates.isEmpty {
                    Firestore.firestore().collection("users").document(uid).updateData(updates)
                }
            }
        }
    }
    
    func updateUserData(name: String? = nil, rank: String? = nil, streak: Int? = nil, weeklyGoal: Int? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        var updates: [String: Any] = [:]
        if let name = name { updates["name"] = name }
        if let rank = rank { updates["rank"] = rank }
        if let streak = streak { updates["streak"] = streak }
        if let weeklyGoal = weeklyGoal { updates["weeklyGoal"] = weeklyGoal }

        Firestore.firestore().collection("users").document(uid).updateData(updates) { error in
            if let error = error {
                print("Failed to update user data:", error.localizedDescription)
            } else {
                print("User data updated successfully")
                self.fetchUserData() // refresh local copy
            }
        }
    }
}
