import SwiftUI

struct RankingPage: View {
    // Sample user data
    @State private var currentUser = User(id: "user", name: "Adam Horvitz", steps: 50000, rank: "Gold", avatarSymbol: "person.crop.circle.fill")
    @State private var friends = [
        User(id: "friend1", name: "Sarah Johnson", steps: 62480, rank: "Platinum", avatarSymbol: "person.crop.circle.fill"),
        User(id: "friend2", name: "Mike Chen", steps: 45320, rank: "Gold", avatarSymbol: "person.crop.circle.fill"),
        User(id: "friend3", name: "Emily Davis", steps: 38750, rank: "Silver", avatarSymbol: "person.crop.circle.fill"),
        User(id: "friend4", name: "Carlos Rodriguez", steps: 28960, rank: "Bronze", avatarSymbol: "person.crop.circle.fill")
    ]
    
    // Combined and sorted list
    private var allUsers: [User] {
        var combined = friends
        combined.append(currentUser)
        return combined.sorted { $0.steps > $1.steps }
    }
    
    // Get position of current user
    private var userRank: Int {
        if let index = allUsers.firstIndex(where: { $0.id == currentUser.id }) {
            return index + 1
        }
        return 0
    }
    
    // Get top stepper
    private var topStepper: User {
        return allUsers.first!
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient - same as UserPage
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]),
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                // Add a ScrollView to make content scrollable
                ScrollView {
                    VStack(spacing: 40) {  // Increased overall spacing between main components to 45
                        // Top leader section
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            
                            VStack(spacing: 15) {  // Increased internal spacing
                                Text("This Week's Leader")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundColor(.gray.opacity(0.8))
                                    .padding(.bottom, 15)
                                
                                ZStack {
                                    // Crown for the leader
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.yellow)
                                        .offset(y: -55)
                                        .padding(.top, 5)
                                    
                                    // Leader avatar
                                    ZStack {
                                        Circle()
                                            .fill(LinearGradient(
                                                gradient: Gradient(colors: [.purple, .blue]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ))
                                            .frame(width: 95, height: 95)
                                        
                                        Image(systemName: topStepper.avatarSymbol)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 80, height: 80)
                                            .foregroundColor(.white)
                                            .background(Color.gray.clipShape(Circle()))
                                    }
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
                        .frame(height: 240)  // Slightly increased height
                        .padding(.horizontal)
                        .padding(.top, 15)  // Added top padding
                        .padding(.bottom, 20)
                        
                        // User's current ranking
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            
                            VStack(spacing: 15) {  // Increased spacing
                                Text("Your Current Ranking")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.gray.opacity(0.8))
                                    .padding(.top, 5)  // Added top padding
                                
                                HStack(alignment: .center, spacing: 15) {
                                    Text("#\(userRank)")
                                        .font(.system(size: 34, weight: .bold, design: .rounded))
                                        .foregroundColor(.blue)
                                    
                                    Divider()
                                        .frame(height: 40)
                                    
                                    VStack(alignment: .leading, spacing: 5) {  // Increased spacing
                                        Text(currentUser.name)
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                        
                                        Text("\(currentUser.steps.formattedWithCommas) steps")
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    // Show distance to next rank or crown if first
                                    if userRank > 1 {
                                        let stepsToNext = allUsers[userRank-2].steps - currentUser.steps
                                        VStack(alignment: .trailing, spacing: 5) {  // Increased spacing
                                            Text("\(stepsToNext.formattedWithCommas)")
                                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                                .foregroundColor(.orange)
                                            
                                            Text("steps to #\(userRank-1)")
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
                                .padding(.bottom, 5)  // Added bottom padding
                            }
                            .padding()
                        }
                        .frame(height: 120)
                        .padding(.horizontal)
                        
                        // Leaderboard
                        VStack(alignment: .leading, spacing: 20) {  // Increased spacing
                            Text("Weekly Leaderboard")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .padding(.horizontal)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                                
                                VStack(spacing: 0) {
                                    ForEach(Array(allUsers.enumerated()), id: \.element.id) { index, user in
                                        LeaderboardRow(
                                            rank: index + 1,
                                            user: user,
                                            isCurrentUser: user.id == currentUser.id
                                        )
                                        
                                        if index < allUsers.count - 1 {
                                            Divider()
                                                .padding(.horizontal)
                                        }
                                    }
                                }
                                .padding(.vertical, 15)  // Increased vertical padding
                            }
                            .padding(.horizontal)
                        }
                        
                        // Added bottom spacing to ensure there's room at the bottom of the ScrollView
                        Spacer(minLength: 40)
                    }
                    .padding(.top)
                }
                // Enable scrolling indicators for better UX
                .scrollIndicators(.visible)
            }
            .navigationTitle("Rankings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
//        .refreshable(){
//
//        }
    }
}

// Leaderboard row for each user
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

// User data model
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
