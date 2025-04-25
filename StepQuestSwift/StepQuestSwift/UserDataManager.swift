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

class UserDataManager: ObservableObject {
    @Published var name: String = ""
    @Published var tier: String = ""
    @Published var streak: Int = 0
    @Published var weeklyGoal: Int = 20000
    @Published var weeklyStepCount: Int = 0
    @Published var friends: [String] = []
    @Published var friendsData: [UserProfile] = []
    @Published var friendCode: String = ""
    @Published var globalLeaderboardData: [UserProfile] = []
    @Published var avatarSymbol: String = "person.crop.circle"
    @Published var profileImageName: String = "BlueProfile"
    @Published var profilePicture: String = "BlueProfile"
    
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
                self.friends = data["friends"] as? [String] ?? []
                self.avatarSymbol = data["avatarSymbol"] as? String ?? "person.crop.circle"
                var updates: [String: Any] = [:]
                if data["friendCode"] == nil {
                    let code = Self.generateFriendCode()
                    updates["friendCode"] = code
                    self.friendCode = code
                } else {
                    self.friendCode = data["friendCode"] as? String ?? ""
                }

                //pATCH missing fields back to firestore
                if data["tier"] == nil { updates["tier"] = "Bronze" }
                if data["streak"] == nil { updates["streak"] = 0 }
                if data["weeklyGoal"] == nil { updates["weeklyGoal"] = 20000 }
                if data["weeklyStepCount"] == nil { updates["weeklyStepCount"] = 0 }
                if data["friends"] == nil { updates["friends"] = [] }
                if data["avatarSymbol"] == nil { updates["avatarSymbol"] = "person.crop.circle" }
                if data["profileImageName"] == nil { updates["profileImageName"] = "BlueProfile" }

                if !updates.isEmpty {
                    Firestore.firestore().collection("users").document(uid).updateData(updates) { _ in
                        let fetchedProfileImageName = data["profileImageName"] as? String
                        self.profileImageName = fetchedProfileImageName ?? "BlueProfile"
                        self.profilePicture = fetchedProfileImageName ?? "BlueProfile"
                        self.fetchFriendsData()
                    }
                } else {
                    let fetchedProfileImageName = data["profileImageName"] as? String
                    self.profileImageName = fetchedProfileImageName ?? "BlueProfile"
                    self.profilePicture = fetchedProfileImageName ?? "BlueProfile"
                    self.fetchFriendsData()
                }
            }
        }
    }
    
    func updateUserData(
        name: String? = nil,
        tier: String? = nil,
        streak: Int? = nil,
        weeklyGoal: Int? = nil,
        weeklyStepCount: Int? = nil,
        avatarSymbol: String? = nil,
        profileImageName: String? = nil
    ) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        var updates: [String: Any] = [:]
        if let name = name { updates["name"] = name }
        if let tier = tier { updates["tier"] = tier }
        if let streak = streak { updates["streak"] = streak }
        if let weeklyGoal = weeklyGoal { updates["weeklyGoal"] = weeklyGoal }
        if let weeklyStepCount = weeklyStepCount { updates["weeklyStepCount"] = weeklyStepCount }
        if let avatarSymbol = avatarSymbol { updates["avatarSymbol"] = avatarSymbol }
        if let profileImageName = profileImageName {
            updates["profileImageName"] = profileImageName
            self.profileImageName = profileImageName
            self.profilePicture = profileImageName
            self.objectWillChange.send()
        }

        Firestore.firestore().collection("users").document(uid).updateData(updates) { error in
            if let error = error {
                print("Failed to update user data:", error.localizedDescription)
            } else {
                print("User data updated successfully")
                self.fetchUserData() // refresh local copy

                self.fetchAllUsersForLeaderboard { profiles in
                    DispatchQueue.main.async {
                        self.globalLeaderboardData = profiles
                        self.objectWillChange.send()
                    }
                }
            }
        }
    }

    
    func fetchFriendsData() {
        friendsData = [] // clear old list
        for friendUID in friends {
            Firestore.firestore().collection("users").document(friendUID).getDocument { document, error in
                guard let document = document, document.exists,
                      let data = document.data() else {
                    print("Failed to fetch friend \(friendUID):", error?.localizedDescription ?? "Unknown error")
                    return
                }

                let profile = UserProfile(
                    id: friendUID,
                    name: data["name"] as? String ?? "Unknown",
                    tier: data["tier"] as? String ?? "Bronze",
                    weeklyStepCount: data["weeklyStepCount"] as? Int ?? 0,
                    streak: data["streak"] as? Int ?? 0,
                    avatarSymbol: data["avatarSymbol"] as? String,
                    profileImageName: data["profileImageName"] as? String ?? "BlueProfile"
                )

                DispatchQueue.main.async {
                    self.friendsData.append(profile)
                }
            }
        }
    }
    
    func addFriendByFriendCode(friendCode: String) {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("users")
            .whereField("friendCode", isEqualTo: friendCode)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error searching for friend:", error.localizedDescription)
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    print("No user found with that friend code")
                    return
                }

                let friendUID = document.documentID
                guard friendUID != currentUID else {
                    print("You can't add yourself as a friend.")
                    return
                }

                self.addFriendByUid(uid: friendUID)
            }
    }
    
    func addFriendByUid(uid: String) {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(currentUID)

        // Only add if not already in list
        guard !self.friends.contains(uid) else {
            print("Friend already added.")
            return
        }

        userRef.updateData([
            "friends": FieldValue.arrayUnion([uid])
        ]) { error in
            if let error = error {
                print("Failed to add friend:", error.localizedDescription)
            } else {
                print("Friend added!")
                self.fetchUserData()
            }
        }
    }

    static func generateFriendCode() -> String {
        func randomLetters(_ length: Int) -> String {
            let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            return String((0..<length).map { _ in letters.randomElement()! })
        }

        func randomDigits(_ length: Int) -> String {
            let digits = "0123456789"
            return String((0..<length).map { _ in digits.randomElement()! })
        }

        let part1 = randomLetters(4)
        let part2 = randomDigits(4)
        let part3 = randomLetters(3)

        return "\(part1)-\(part2)-\(part3)"
    }
    
    func fetchAllUsersForLeaderboard(completion: @escaping ([UserProfile]) -> Void) {
        Firestore.firestore().collection("users").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Failed to fetch global users:", error?.localizedDescription ?? "Unknown error")
                completion([])
                return
            }

            let profiles: [UserProfile] = documents.compactMap { doc in
                let data = doc.data()
                return UserProfile(
                    id: doc.documentID,
                    name: data["name"] as? String ?? "Unknown",
                    tier: data["tier"] as? String ?? "Bronze",
                    weeklyStepCount: data["weeklyStepCount"] as? Int ?? 0,
                    streak: data["streak"] as? Int ?? 0,
                    avatarSymbol: data["avatarSymbol"] as? String,
                    profileImageName: data["profileImageName"] as? String ?? "BlueProfile"
                )
            }

            DispatchQueue.main.async {
                completion(profiles)
            }
        }
    }
}

struct UserProfile: Identifiable, Equatable {
    var id: String // uid
    var name: String
    var tier: String
    var weeklyStepCount: Int
    var streak: Int?
    var avatarSymbol: String?
    var profileImageName: String?
}
