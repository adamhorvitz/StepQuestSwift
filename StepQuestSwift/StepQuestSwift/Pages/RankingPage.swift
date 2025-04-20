import SwiftUI
import FirebaseAuth

struct RankingPage: View {
    @EnvironmentObject var healthManager: HealthManager
    @EnvironmentObject var userDataManager: UserDataManager

    @State private var allUsersFromDB: [User] = []

    // Sorted users from Firestore
    private var allUsers: [User] {
        allUsersFromDB.sorted { $0.steps > $1.steps }
    }

    // Top 5 users
    private var topFiveUsers: [User] {
        Array(allUsers.prefix(5))
    }

    // User's rank in list
    private var userRank: Int {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return 0 }
        return (allUsers.firstIndex(where: { $0.id == currentUserID }) ?? -1) + 1
    }

    // Top user or fallback
    private var topStepper: User {
        allUsers.first ?? User(id: "placeholder", name: "No users yet", steps: 0, rank: "None", avatarSymbol: "person.crop.circle")
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]),
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 40) {
                        // Top user section
                        TopUser(topStepper: topStepper)

                        // Current user's rank (optional: only show if user is in list)
                        if let currentUserID = Auth.auth().currentUser?.uid,
                           let currentUser = allUsers.first(where: { $0.id == currentUserID }) {
                            UserRankSection(user: currentUser, rank: userRank, allUsers: allUsers)
                        }

                        // Leaderboard
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Weekly Leaderboard")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .padding(.horizontal)

                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

                                VStack(spacing: 0) {
                                    ForEach(Array(topFiveUsers.enumerated()), id: \.element.id) { index, user in
                                        LeaderboardRow(
                                            rank: index + 1,
                                            user: user,
                                            isCurrentUser: user.id == Auth.auth().currentUser?.uid
                                        )

                                        if index < topFiveUsers.count - 1 {
                                            Divider()
                                                .padding(.horizontal)
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
                    .onAppear {
                        userDataManager.fetchAllUsers { users in
                            self.allUsersFromDB = users
                        }
                        healthManager.fetchStepCount()
                    }
                }
                .scrollIndicators(.visible)
            }
            .navigationTitle("Rankings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        userDataManager.fetchAllUsers { users in
                            self.allUsersFromDB = users
                        }
                        healthManager.fetchStepCount()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

struct UserRankSection: View {
    var user: User
    var rank: Int
    var allUsers: [User]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

            VStack(spacing: 15) {
                Text("Your Current Ranking")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.gray.opacity(0.8))
                    .padding(.top, 5)

                HStack(spacing: 15) {
                    Text("#\(rank)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)

                    Divider().frame(height: 40)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(user.name)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Text("\(user.steps.formattedWithCommas) steps")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    if rank > 1 {
                        let stepsToNext = allUsers[rank - 2].steps - user.steps
                        VStack(alignment: .trailing, spacing: 5) {
                            Text("\(stepsToNext.formattedWithCommas)")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.orange)
                            Text("to #\(rank - 1)")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
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



struct LeaderboardRow: View {
    let rank: Int
    let user: User
    let isCurrentUser: Bool

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
            ZStack {
                Circle()
                    .fill(rankColor.opacity(0.2))
                    .frame(width: 36, height: 36)

                Text("\(rank)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(rankColor)
            }

            Image(systemName: user.avatarSymbol)
                .font(.system(size: 22))
                .foregroundColor(isCurrentUser ? .blue : .gray)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(isCurrentUser ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                )

            Text(user.name)
                .font(.system(size: 16, weight: isCurrentUser ? .bold : .medium, design: .rounded))
                .foregroundColor(isCurrentUser ? .primary : .gray)

            Spacer()

            Text("\(user.steps.formattedWithCommas)")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(isCurrentUser ? .blue : .gray)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(isCurrentUser ? Color.blue.opacity(0.05) : Color.clear)
        .cornerRadius(10)
    }
}

struct TopUser: View {
    var topStepper: User

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

            VStack(spacing: 15) {
                Text("This Week's Leader")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.gray.opacity(0.8))
                    .padding(.bottom, 15)

                ZStack {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.yellow)
                        .offset(y: -55)
                        .padding(.top, 5)

                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.purple, .blue]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 95, height: 95)
                        .overlay(
                            Image(systemName: topStepper.avatarSymbol)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .foregroundColor(.white)
                        )
                }

                Text(topStepper.name)
                    .font(.system(size: 20, weight: .bold, design: .rounded))

                Text("\(topStepper.steps.formattedWithCommas) steps")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.blue)

                Text(topStepper.rank)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.purple)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(12)
            }
            .padding()
        }
        .frame(height: 240)
        .padding(.horizontal)
        .padding(.top, 15)
        .padding(.bottom, 20)
    }
}


extension Int {
    var formattedWithCommas: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self)) ?? String(self)
    }
}

#Preview {
    RankingPage()
        .environmentObject(HealthManager())
        .environmentObject(UserDataManager())
}
