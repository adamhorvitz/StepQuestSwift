import SwiftUI

struct RankingPage: View {
    @EnvironmentObject var userDataManager: UserDataManager

    private var allUsers: [User] {
        let current = User(
            id: "current",
            name: userDataManager.name,
            steps: userDataManager.weeklyStepCount,
            rank: userDataManager.tier,
            avatarSymbol: "person.crop.circle.fill"
        )

        let friends = userDataManager.friendsData.map {
            User(
                id: $0.id,
                name: $0.name,
                steps: $0.weeklyStepCount,
                rank: $0.tier,
                avatarSymbol: "person.crop.circle.fill"
            )
        }

        var combined = friends
        combined.append(current)
        return combined.sorted { $0.steps > $1.steps }
    }

    private var userRank: Int {
        (allUsers.firstIndex(where: { $0.id == "current" }) ?? -1) + 1
    }

    private var topStepper: User {
        allUsers.first ?? User(id: "", name: "", steps: 0, rank: "", avatarSymbol: "")
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]),
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 40) {
                        TopUser(topStepper: topStepper)

                        if let currentUser = allUsers.first(where: { $0.id == "current" }) {
                            UserRankSection(user: currentUser, rank: userRank, allUsers: allUsers)
                        }

                        VStack(alignment: .leading, spacing: 20) {
                            Text("Weekly Leaderboard")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .padding(.horizontal)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

                                VStack(spacing: 0) {
                                    ForEach(Array(allUsers.enumerated()), id: \.element.id) { index, user in
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
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(rankColor)
            }
            
            // User avatar
            Image(systemName: user.avatarSymbol)
                .font(.system(size: 22))
                .foregroundColor(isCurrentUser ? .blue : .gray)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(isCurrentUser ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                )
            
            // User name
            Text(user.name)
                .font(.system(size: 16, weight: isCurrentUser ? .bold : .medium, design: .rounded))
                .foregroundColor(isCurrentUser ? .primary : .gray)
            
            Spacer()
            
            // Step count
            Text("\(user.steps.formattedWithCommas)")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(isCurrentUser ? .blue : .gray)
        }
        .padding(.vertical, 12)  // Increased vertical padding
        .padding(.horizontal, 16)
        .background(isCurrentUser ? Color.blue.opacity(0.05) : Color.clear)
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
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

            VStack(spacing: 15) {
                Text("Your Current Ranking")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.gray.opacity(0.8))

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
                            Text("steps to #\(rank - 1)")
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

//topuser as weeks leader
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
                        .fill(LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
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
    }
}

struct User: Identifiable, Equatable {
    var id: String
    var name: String
    var steps: Int
    var rank: String
    var avatarSymbol: String
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
