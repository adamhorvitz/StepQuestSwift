//
//  FriendsPage.swift
//  StepQuestSwift
//
//  Created on 3/8/25.
//

import SwiftUI

struct FriendsPage: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var showAddFriendSheet = false
    @State private var showCreateGroupSheet = false
    
    private let groups = [
        Group(id: 1, name: "Weekend Warriors", members: 4, totalSteps: 239000),
        Group(id: 2, name: "Office Step Challenge", members: 6, totalSteps: 352000)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Custom dark brown background
                Color(red: 0.1, green: 0.05, blue: 0.02)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Custom segmented control
                    HStack(spacing: 0) {
                        TabButton(text: "Friends", isSelected: selectedTab == 0) {
                            withAnimation { selectedTab = 0 }
                        }
                        
                        TabButton(text: "Groups", isSelected: selectedTab == 1) {
                            withAnimation { selectedTab = 1 }
                        }
                    }
                    .background(Color(red: 0.1, green: 0.05, blue: 0.02))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(red: 1, green: 0.95, blue: 0.8).opacity(0.7))
                        
                        TextField("Search", text: $searchText)
                            .font(.custom("Press Start 2P", size: 13))
                            .foregroundColor(Color(red: 1, green: 0.95, blue: 0.8).opacity(0.7))
                    }
                    .padding()
                    .background(Color(red: 0.2, green: 0.15, blue: 0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Content based on selected tab
                    if selectedTab == 0 {
                        // Friends list
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(userDataManager.friendsData) { friend in
                                    FriendCard(friend: friend)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 80) // Extra padding for FAB
                        }
                        .onAppear {
                            userDataManager.fetchFriendsData()
                        }
                    } else {
                        // Groups list
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(groups) { group in
                                    GroupCard(group: group)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 80) // Extra padding for FAB
                        }
                    }
                    
                    Spacer()
                }
                
                // Floating action button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            if selectedTab == 0 {
                                showAddFriendSheet = true
                            } else {
                                showCreateGroupSheet = true
                            }
                        }) {
                            Image(systemName: selectedTab == 0 ? "person.badge.plus" : "person.3.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [.blue, .purple]),
                                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Friends & Groups")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAddFriendSheet) {
                AddFriendView()
                    .environmentObject(userDataManager)
            }
            .sheet(isPresented: $showCreateGroupSheet) {
                CreateGroupView()
            }
        }
        .onAppear {
            userDataManager.fetchUserData()
        }
    }
}

// MARK: - Supporting Views

struct TabButton: View {
    var text: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.custom("Press Start 2P", size: 13))
                .padding(.vertical, 12)
                .padding(.horizontal, 30)
                .background(isSelected ? Color(red: 0.2, green: 0.15, blue: 0.1) : Color.clear)
                .cornerRadius(10)
                .foregroundColor(isSelected ? Color(red: 1, green: 0.95, blue: 0.8) : Color(red: 1, green: 0.95, blue: 0.8).opacity(0.7))
        }
    }
}

struct FriendCard: View {
    var friend: UserProfile
    
    // Get appropriate rank color
    private func rankColor(for rank: String) -> Color {
        switch rank {
        case "Gold":
            return .yellow
        case "Silver":
            return .gray
        case "Platinum":
            return .purple
        default:
            return .brown
        }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 60, height: 60)
                    .overlay(Circle().stroke(Color(red: 1, green: 0.95, blue: 0.8), lineWidth: 2))
                Image(friend.profileImageName ?? "BlueProfile")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 54, height: 54)
                    .clipShape(Circle())
            }
            
            // Friend info
            VStack(alignment: .leading, spacing: 5) {
                Text(friend.name)
                    .font(.custom("Press Start 2P", size: 14))
                    .foregroundColor(Color(red: 1, green: 0.95, blue: 0.8))
                
                HStack(spacing: 10) {
                    // Compact badges
                    HStack(spacing: 4) {
                        Image(systemName: "shoeprints.fill")
                            .foregroundColor(.blue)
                        Text(formatNumber(friend.weeklyStepCount))
                            .font(.custom("Press Start 2P", size: 10))
                            .foregroundColor(Color(red: 1, green: 0.95, blue: 0.8).opacity(0.7))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .foregroundColor(rankColor(for: friend.tier))
//                        Text(friend.rank)
                            .font(.system(size: 22))
                    }
                    
                    if let streak = friend.streak {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.red)
                            Text("\(streak)")
                                .font(.custom("Press Start 2P", size: 10))
                                .foregroundColor(Color(red: 1, green: 0.95, blue: 0.8).opacity(0.7))
                        }
                    }
                }
            }
            
            Spacer()
            
            // Challenge button
            Button(action: {}) {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [.orange, .yellow]),
                                      startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color(red: 0.2, green: 0.15, blue: 0.1))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
}

struct GroupCard: View {
    var group: Group
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Group header
            HStack {
                Text(group.name)
                    .font(.custom("Press Start 2P", size: 14))
                    .foregroundColor(Color(red: 1, green: 0.95, blue: 0.8))
                
                Spacer()
                
                // View members button
                Button(action: {}) {
                    HStack(spacing: 5) {
                        Text("View")
                            .font(.custom("Press Start 2P", size: 10))
                        Image(systemName: "chevron.right")
                            .font(.custom("Press Start 2P", size: 8))
                    }
                    .foregroundColor(Color(red: 1, green: 0.95, blue: 0.8).opacity(0.7))
                }
            }
            
            Divider()
            
            // Group stats
            HStack(spacing: 25) {
                // Members count
                VStack {
                    Text("\(group.members)")
                        .font(.custom("Press Start 2P", size: 18))
                        .foregroundColor(.blue)
                    
                    Text("Members")
                        .font(.custom("Press Start 2P", size: 10))
                        .foregroundColor(Color(red: 1, green: 0.95, blue: 0.8).opacity(0.7))
                }
                
                // Steps count
                VStack {
                    Text("\(group.totalSteps)")
                        .font(.custom("Press Start 2P", size: 18))
                        .foregroundColor(.green)
                    
                    Text("Total Steps")
                        .font(.custom("Press Start 2P", size: 10))
                        .foregroundColor(Color(red: 1, green: 0.95, blue: 0.8).opacity(0.7))
                }
                
                Spacer()
                
                // Group rank visualized
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 5)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            LinearGradient(gradient: Gradient(colors: [.blue, .purple]),
                                         startPoint: .leading, endPoint: .trailing),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                    
                    Text("2nd")
                        .font(.custom("Press Start 2P", size: 10))
                        .foregroundColor(Color(red: 1, green: 0.95, blue: 0.8))
                }
            }
            .padding(.vertical, 5)
        }
        .padding()
        .background(Color(red: 0.2, green: 0.15, blue: 0.1))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
}

struct AddFriendView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var friendCode = UserDataManager.generateFriendCode()
    @State private var searchQuery = ""
    @State private var inputCode = ""
    @State private var successMessage = ""
    @State private var showSuccessMessage = false
            
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                // Friend code section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Add Friend by Code")
                        .font(.custom("Press Start 2P", size: 13))
                        .foregroundColor(Color(red: 1, green: 0.95, blue: 0.8))
                    
                    HStack {
                        TextField("Enter friend code", text: $inputCode)
                            .font(.custom("Press Start 2P", size: 12))
                            .padding()
                            .background(Color(red: 0.2, green: 0.15, blue: 0.1))
                            .cornerRadius(10)
                        
                        Button(action: {
                            userDataManager.addFriendByFriendCode(friendCode: inputCode)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                userDataManager.fetchFriendsData()
                                successMessage = "Friend added successfully!"
                                showSuccessMessage = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showSuccessMessage = false
                                }
                            }
                        }) {
                            Text("Add")
                                .font(.custom("Press Start 2P", size: 12))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 15)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
                
                Divider()
                
                // Search section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Find Friends")
                        .font(.custom("Press Start 2P", size: 13))
                        .foregroundColor(Color(red: 1, green: 0.95, blue: 0.8))
                    
                    TextField("Search by name or email", text: $searchQuery)
                        .font(.custom("Press Start 2P", size: 12))
                        .padding()
                        .background(Color(red: 0.2, green: 0.15, blue: 0.1))
                        .cornerRadius(10)
                }
                .padding()
                
                VStack(spacing: 15) {
                    Text("Your Friend Code")
                        .font(.custom("Press Start 2P", size: 13))
                        .foregroundColor(Color(red: 1, green: 0.95, blue: 0.8))
                    
                    Text(userDataManager.friendCode)
                        .font(.custom("Press Start 2P", size: 16))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(Color(red: 1, green: 0.95, blue: 0.8))
                    
                    Button(action: {UIPasteboard.general.string = userDataManager.friendCode
                    }) {
                        HStack {
                            Image(systemName: "square.on.square")
                            Text("Copy Code")
                        }
                        .font(.custom("Press Start 2P", size: 12))
                        .foregroundColor(Color(red: 1, green: 0.95, blue: 0.8).opacity(0.7))
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Add Friends")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .alert("Friend added successfully!", isPresented: $showSuccessMessage) {
            Button("OK", role: .cancel) { }
        }
    }
}

struct CreateGroupView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var groupName = ""
    @State private var isPublic = false
    @State private var weeklyGoal = 100000
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Group Details")
                    .font(.custom("Press Start 2P", size: 13))
                    .foregroundColor(Color(red: 1, green: 0.95, blue: 0.8))
                ) {
                    TextField("Group Name", text: $groupName)
                        .font(.custom("Press Start 2P", size: 12))
                    
                    Toggle("Public Group", isOn: $isPublic)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .font(.custom("Press Start 2P", size: 12))
                    
                    Text("Public groups can be found by anyone. Private groups require an invitation.")
                        .font(.custom("Press Start 2P", size: 10))
                        .foregroundColor(Color(red: 1, green: 0.95, blue: 0.8).opacity(0.7))
                }
                
                Section(header: Text("Weekly Step Goal")
                    .font(.custom("Press Start 2P", size: 13))
                    .foregroundColor(Color(red: 1, green: 0.95, blue: 0.8))
                ) {
                    Stepper("\(weeklyGoal) steps", value: $weeklyGoal, in: 50000...500000, step: 10000)
                        .font(.custom("Press Start 2P", size: 12))
                }
                
                Section {
                    Button(action: {
                        // Create group logic would go here
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Create Group")
                            .font(.custom("Press Start 2P", size: 13))
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Create New Group")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

private func formatNumber(_ number: Int) -> String {
    if number >= 1000 {
        return "\(number / 1000)k"
    }
    return "\(number)"
}


// MARK: - Models

struct Friend: Identifiable {
    var id: Int
    var name: String
    var stepCount: Int
    var rank: String
    var streak: Int
}

struct Group: Identifiable {
    var id: Int
    var name: String
    var members: Int
    var totalSteps: Int
}

#Preview {
    FriendsPage()
}
