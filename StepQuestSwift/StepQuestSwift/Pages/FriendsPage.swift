//
//  FriendsPage.swift
//  StepQuestSwift
//
//  Created on 3/8/25.
//

import SwiftUI

struct FriendsPage: View {
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var showAddFriendSheet = false
    @State private var showCreateGroupSheet = false
    
    // Sample data
    private let friends = [
        Friend(id: 1, name: "Sarah Johnson", stepCount: 62000, rank: "Gold", streak: 14),
        Friend(id: 2, name: "Mike Chen", stepCount: 48000, rank: "Silver", streak: 5),
        Friend(id: 3, name: "Taylor Swift", stepCount: 71000, rank: "Platinum", streak: 21)
    ]
    
    private let groups = [
        Group(id: 1, name: "Weekend Warriors", members: 4, totalSteps: 239000),
        Group(id: 2, name: "Office Step Challenge", members: 6, totalSteps: 352000)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]),
                              startPoint: .top, endPoint: .bottom)
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
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search", text: $searchText)
                            .font(.system(size: 16))
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Content based on selected tab
                    if selectedTab == 0 {
                        // Friends list
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(friends) { friend in
                                    FriendCard(friend: friend)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 80) // Extra padding for FAB
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
            }
            .sheet(isPresented: $showCreateGroupSheet) {
                CreateGroupView()
            }
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
                .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                .padding(.vertical, 12)
                .padding(.horizontal, 30)
                .background(isSelected ? Color.white : Color.clear)
                .cornerRadius(10)
                .foregroundColor(isSelected ? .blue : .gray)
        }
    }
}

struct FriendCard: View {
    var friend: Friend
    
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
            return .blue
        }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
            }
            
            // Friend info
            VStack(alignment: .leading, spacing: 5) {
                Text(friend.name)
                    .font(.system(size: 18, weight: .semibold))
                
                HStack(spacing: 10) {
                    // Compact badges
                    HStack(spacing: 4) {
                        Image(systemName: "shoeprints.fill")
                            .foregroundColor(.blue)
                        Text(formatNumber(friend.stepCount))
                            .font(.system(size: 14))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .foregroundColor(rankColor(for: friend.rank))
//                        Text(friend.rank)
                            .font(.system(size: 22))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.red)
                        Text("\(friend.streak)")
                            .font(.system(size: 14))
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
        .background(Color.white)
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
                    .font(.system(size: 18, weight: .bold))
                
                Spacer()
                
                // View members button
                Button(action: {}) {
                    HStack(spacing: 5) {
                        Text("View")
                            .font(.system(size: 14, weight: .medium))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.blue)
                }
            }
            
            Divider()
            
            // Group stats
            HStack(spacing: 25) {
                // Members count
                VStack {
                    Text("\(group.members)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("Members")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                // Steps count
                VStack {
                    Text("\(group.totalSteps)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.green)
                    
                    Text("Total Steps")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
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
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .padding(.vertical, 5)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
}

struct AddFriendView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var friendCode = ""
    @State private var searchQuery = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                // Friend code section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Add Friend by Code")
                        .font(.headline)
                    
                    HStack {
                        TextField("Enter friend code", text: $friendCode)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        
                        Button(action: {}) {
                            Text("Add")
                                .fontWeight(.semibold)
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
                        .font(.headline)
                    
                    TextField("Search by name or email", text: $searchQuery)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding()
                
                // Your code section
                VStack(spacing: 15) {
                    Text("Your Friend Code")
                        .font(.headline)
                    
                    Text("STEP-5678-XYZ")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "square.on.square")
                            Text("Copy Code")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
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
                Section(header: Text("Group Details")) {
                    TextField("Group Name", text: $groupName)
                    
                    Toggle("Public Group", isOn: $isPublic)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    
                    Text("Public groups can be found by anyone. Private groups require an invitation.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Section(header: Text("Weekly Step Goal")) {
                    Stepper("\(weeklyGoal) steps", value: $weeklyGoal, in: 50000...500000, step: 10000)
                }
                
                Section {
                    Button(action: {
                        // Create group logic would go here
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Create Group")
                            .fontWeight(.bold)
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
