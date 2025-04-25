import SwiftUI
import Firebase
import FirebaseAuth

struct RankingPage: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var allUsers: [User] = []

    private func loadAllUsers() {
        let currentUID = Auth.auth().currentUser?.uid
        let profiles = userDataManager.globalLeaderboardData

        self.allUsers = profiles.map { profile in
            User(
                id: profile.id == currentUID ? "current" : profile.id,
                name: profile.name,
                steps: profile.weeklyStepCount,
                rank: profile.tier,
                avatarImageName: profile.profileImageName ?? "BlueProfile"
            )
        }.sorted { $0.steps > $1.steps }
    }

    private var userRank: Int {
        (allUsers.firstIndex(where: { $0.id == "current" }) ?? -1) + 1
    }

    private var topStepper: User {
        allUsers.first ?? User(id: "", name: "", steps: 0, rank: "", avatarImageName: "BlueProfile")
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.3, green: 0.2, blue: 0.1)
                    .ignoresSafeArea()

                if userDataManager.globalLeaderboardData.isEmpty {
                    ProgressView("Loading leaderboard...")
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 40) {
                            TopUser(topStepper: topStepper)

                            if let currentUser = allUsers.first(where: { $0.id == "current" }) {
                                UserRankSection(user: currentUser, rank: userRank, allUsers: allUsers)
                            }

                            VStack(alignment: .leading, spacing: 15) {
                                Text("Weekly Leaderboard")
                                    .font(.custom("Press Start 2P", size: 14))
                                    .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.1))
                                    .padding(.horizontal)
                                
                                Text("Showing Top 10")
                                    .font(.custom("Press Start 2P", size: 12))
                                    .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.1).opacity(0.7))
                                    .padding(.horizontal)

                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(red: 0.87, green: 0.75, blue: 0.6))
                                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

                                    VStack(spacing: 0) {
                                        ForEach(Array(allUsers.prefix(10).enumerated()), id: \.element.id) { index, user in
                                            LeaderboardRow(rank: index + 1, user: user, isCurrentUser: user.id == "current")

                                            if index < allUsers.count - 1 {
                                                Divider().padding(.horizontal)
                                            }
                                        }
                                    }
                                    .padding(.vertical, 15)
                                }
                                .padding(.horizontal)
                            }

                            Spacer(minLength: 40)
                        }
                        .padding(.top)
                    }
                }
            }
            .onAppear {
                userDataManager.fetchAllUsersForLeaderboard { users in
                    DispatchQueue.main.async {
                        userDataManager.globalLeaderboardData = users
                    }
                }
            }
            .onChange(of: userDataManager.globalLeaderboardData) { _ in
                loadAllUsers()
            }
            .navigationTitle("Rankings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Leaderboard row for each friend in user
struct LeaderboardRow: View {
    let rank: Int
    let user: User
    let isCurrentUser: Bool
    
    // Colors for different ranks
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .brown
        default: return .blue.opacity(0.5)
        }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Rank number
            ZStack {
                Circle()
                    .fill(rankColor.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Text("\(rank)")
                    .font(.custom("Press Start 2P", size: 10))
                    .foregroundColor(rankColor)
            }
            
            // User avatar
            Image(user.avatarImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 36, height: 36)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isCurrentUser ? Color(red: 0.3, green: 0.2, blue: 0.1) : Color.gray, lineWidth: 2)
                )
            
            // User name
            Text(user.name)
                .font(.custom("Press Start 2P", size: 10))
                .foregroundColor(isCurrentUser ? Color(red: 0.3, green: 0.2, blue: 0.1) : Color(red: 0.3, green: 0.2, blue: 0.1).opacity(0.7))
                .fontWeight(isCurrentUser ? .bold : .medium)
            
            Spacer()
            
            // Step count
            Text("\(user.steps.formattedWithCommas)")
                .font(.custom("Press Start 2P", size: 10))
                .foregroundColor(isCurrentUser ? Color(red: 0.3, green: 0.2, blue: 0.1).opacity(0.7) : Color(red: 0.3, green: 0.2, blue: 0.1).opacity(0.7))
                .fontWeight(.semibold)
        }
        .padding(.vertical, 12)  // Increased vertical padding
        .padding(.horizontal, 16)
        .background(isCurrentUser ? Color(red: 0.87, green: 0.75, blue: 0.6).opacity(0.5) : Color.clear)
        .cornerRadius(10)
    }
}

//current user rank
struct UserRankSection: View {
    var user: User
    var rank: Int
    var allUsers: [User]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.87, green: 0.75, blue: 0.6))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

            VStack(spacing: 15) {
                Text("Your Current Ranking")
                    .font(.custom("Press Start 2P", size: 10))
                    .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.1).opacity(0.7))

                HStack(spacing: 15) {
                    Text("#\(rank)")
                        .font(.custom("Press Start 2P", size: 16))
                        .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.1).opacity(0.7))

                    Divider().frame(height: 40)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(user.name)
                            .font(.custom("Press Start 2P", size: 12))
                            .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.1))
                        Text("\(user.steps.formattedWithCommas) steps")
                            .font(.custom("Press Start 2P", size: 10))
                            .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.1).opacity(0.7))
                    }

                    Spacer()

                    if rank > 1 {
                        let stepsToNext = allUsers[rank - 2].steps - user.steps
                        VStack(alignment: .trailing, spacing: 5) {
                            Text("\(stepsToNext.formattedWithCommas)")
                                .font(.custom("Press Start 2P", size: 10))
                                .foregroundColor(.orange)
                            Text("steps to #\(rank - 1)")
                                .font(.custom("Press Start 2P", size: 8))
                                .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.1).opacity(0.7))
                        }
                    } else {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .frame(height: 120)
        .padding(.horizontal)
    }
}

//topuser as weeks leader
struct TopUser: View {
    var topStepper: User

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.87, green: 0.75, blue: 0.6))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

            VStack(spacing: 15) {
                Text("This Week's Leader")
                    .font(.custom("Press Start 2P", size: 10))
                    .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.1).opacity(0.7))
                    .padding(.bottom, 10)

                ZStack {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.yellow)
                        .offset(y: -55)
                        .padding(.top, 5)

                    Circle()
                        .fill(Color(red: 0.87, green: 0.75, blue: 0.6))
                        .frame(width: 95, height: 95)
                        .overlay(
                            Image(topStepper.avatarImageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        )
                }

                Text(topStepper.name)
                    .font(.custom("Press Start 2P", size: 12))
                    .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.1))

                Text("\(topStepper.steps.formattedWithCommas) steps")
                    .font(.custom("Press Start 2P", size: 8))
                    .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.1).opacity(0.7))

                Text(topStepper.rank)
                    .font(.custom("Press Start 2P", size: 8))
                    .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.1).opacity(0.7))
            }
            .padding()
        }
        .frame(height: 240)
        .padding(.horizontal)
        .padding(.top, 15)
    }
}

struct User: Identifiable, Equatable {
    var id: String
    var name: String
    var steps: Int
    var rank: String
    var avatarImageName: String
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}

// Extension to format numbers with commas
extension Int {
    var formattedWithCommas: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self)) ?? String(self)
    }
}

#Preview {
    RankingPage()
}
