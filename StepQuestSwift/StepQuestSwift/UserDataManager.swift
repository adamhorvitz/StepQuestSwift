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
    @Published var tier: String = ""
    @Published var streak: Int = 0
    @Published var weeklyGoal: Int = 20000
    @Published var weeklyStepCount: Int = 0

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
                self.tier = data["tier"] as? String ?? "Bronze"
                self.streak = data["streak"] as? Int ?? 0
                self.weeklyGoal = data["weeklyGoal"] as? Int ?? 20000
                self.weeklyStepCount = data["weeklyStepCount"] as? Int ?? 0

                //pATCH missing fields back to firestore
                var updates: [String: Any] = [:]
                if data["tier"] == nil { updates["tier"] = "Bronze" }
                if data["streak"] == nil { updates["streak"] = 0 }
                if data["weeklyGoal"] == nil { updates["weeklyGoal"] = 20000 }
                if data["weeklyStepCount"] == nil { updates["weeklyStepCount"] = 0 }

                if !updates.isEmpty {
                    Firestore.firestore().collection("users").document(uid).updateData(updates)
                }
            }
        }
    }
    
    func updateUserData(name: String? = nil, tier: String? = nil, streak: Int? = nil, weeklyGoal: Int? = nil, weeklyStepCount: Int? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        var updates: [String: Any] = [:]
        if let name = name { updates["name"] = name }
        if let tier = tier { updates["tier"] = tier }
        if let streak = streak { updates["streak"] = streak }
        if let weeklyGoal = weeklyGoal { updates["weeklyGoal"] = weeklyGoal }
        if let weeklyStepCount = weeklyStepCount { updates["weeklyStepCount"] = weeklyStepCount }

        Firestore.firestore().collection("users").document(uid).updateData(updates) { error in
            if let error = error {
                print("Failed to update user data:", error.localizedDescription)
            } else {
                print("User data updated successfully")
                self.fetchUserData() // refresh local copy
            }
        }
    }
    
    func fetchAllUsers(completion: @escaping ([User]) -> Void) {
        let db = Firestore.firestore()

        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching all users: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let documents = snapshot?.documents else {
                print("No users found.")
                completion([])
                return
            }

            let users: [User] = documents.compactMap { doc in
                let data = doc.data()
                guard
                    let name = data["name"] as? String,
                    let tier = data["tier"] as? String,
                    let weeklyStepCount = data["weeklyStepCount"] as? Int
                else {
                    return nil
                }

                return User(
                    id: doc.documentID,
                    name: name,
                    steps: weeklyStepCount,
                    rank: tier,
                    avatarSymbol: "person.crop.circle.fill"
                )
            }

            completion(users)
        }
    }

}
