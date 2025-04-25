//
//  UserPage.swift
//  StepQuestSwift
//
//  Created by Adam Horvitz on 3/7/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct UserPage: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var healthManager: HealthManager
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var showingSettings = false
    @State private var showEntrance = true
    @State private var entranceScale: CGFloat = 1.0
    @State private var showProfilePicker = false
    
    var stepCount: Int {
        Int(healthManager.stepCount)
    }
    @State private var animatedProgress: CGFloat = 0.0

    
    // Define gradient colors
    private let goldGradient = LinearGradient(
        gradient: Gradient(colors: [Color.yellow, Color.orange.opacity(0.7)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Calculate percentage of weekly goal (assuming 70,000 steps/week goal)
    private var progressPercentage: CGFloat {
        min(CGFloat(stepCount) / CGFloat(userDataManager.weeklyGoal), 1.0)
    }
        
var body: some View {
    if showEntrance {
        CaveEntranceOverlay(scale: $entranceScale, showEntrance: $showEntrance)
    } else {
    NavigationView {
        ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [Color(red: 40/255, green: 21/255, blue: 31/255), Color(red: 20/255, green: 10/255, blue: 15/255)]),
                              startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 25) {
                        ScrollingBackground(stepCount: stepCount)
                            .padding(.top, -10)

                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 0.87, green: 0.75, blue: 0.6))
                                .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 5)
                            
                            VStack(spacing: 15) {
                                // Avatar with gold border for high tier
                                ZStack {
                                    Circle()
                                        .fill(goldGradient)
                                        .frame(width: 115, height: 115)

                                    Image(userDataManager.profilePicture)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                        .onTapGesture {
                                            showProfilePicker = true
                                        }
                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                }
                                
                                Text(userDataManager.name)
                                    .font(.custom("Press Start 2P", size: 18))
                                    .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.1))
                                
                                // Badge row
                                HStack(spacing: 15) {
                                    LabelBadge(icon: "crown.fill", text: userDataManager.tier, color: .yellow)
                                    LabelBadge(icon: "flame.fill", text: "\(userDataManager.streak) days", color: .red)
                                }
                            }
                        }
                        .frame(height: 250)
                        .padding(.horizontal)
                        
                        // Stats section
                        VStack(spacing: 15) {
                            Text("Weekly Progress")
                                .font(.custom("Press Start 2P", size: 16))
                                .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.1))
                            
                            // Animated progress bar
                            ProgressBar(progress: progressPercentage)
                                .frame(width: UIScreen.main.bounds.width * 0.8)
                            
                            .onAppear {
                                userDataManager.fetchUserData()
                            }
                            .onChange(of: stepCount) {
                                withAnimation(.easeInOut(duration: 1.5)) {
                                    animatedProgress = progressPercentage
                                }
                            }

                            // Step count display
                            HStack {
                                VStack {
                                    Text("\(stepCount)")
                                        .font(.custom("Press Start 2P", size: 18))
                                        .minimumScaleFactor(0.5)
                                        .lineLimit(1)
                                        .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.1))
                                    
                                    Text("Steps")
                                        .font(.custom("Press Start 2P", size: 10))
                                        .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.1))
                                    
                                    Text("this week")
                                        .font(.custom("Press Start 2P", size: 10))
                                        .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.1))
                                }
                                
                                Spacer()
                                
                                // Target display
                                VStack {
                                    Text("\(userDataManager.weeklyGoal)")
                                        .font(.custom("Press Start 2P", size: 18))
                                        .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.1))
                                    
                                    Text("Weekly")
                                        .font(.custom("Press Start 2P", size: 10))
                                        .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.1))
                                        .padding(.top, 4)
                                    
                                    Text("goal")
                                        .font(.custom("Press Start 2P", size: 10))
                                        .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.1))
                                }
                            }
                            .padding(.horizontal, 30)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 0.87, green: 0.75, blue: 0.6))
                                .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)
                        
                        // Achievements section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Recent Achievements")
                                .font(.custom("Press Start 2P", size: 16))
                                .foregroundColor(Color(red: 0.87, green: 0.75, blue: 0.6))
                                .padding(.horizontal)
//                        ScrollView(.horizontal) {
                            HStack(spacing: 15) {
                                AchievementCard(icon: "flame.fill", title: "\(userDataManager.streak) Streak", color: .red)
                                AchievementCard(icon: "figure.walk", title: "\(userDataManager.weeklyGoal/1000)K Steps", color: .blue)
                                AchievementCard(icon: "star.fill", title: "\(userDataManager.tier)", color: .yellow)
                            }
                            .padding(.horizontal)
//                        }
                        }
                        .padding(.top)
                        
                        Spacer()
                    }
                }
                .scrollContentBackground(.hidden)
                .environment(\.colorScheme, .dark)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("User Profile")
                        .font(.custom("Press Start 2P", size: 14))
                        .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.1))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(Color.cyan)
                    }
                }
            }
            .tint(Color(red: 0.87, green: 0.75, blue: 0.6))
            .sheet(isPresented: $showingSettings) {
                SettingsPage()
                    .environmentObject(userDataManager)
            }
            .onAppear {
                UIScrollView.appearance().indicatorStyle = .white // change this to .black if using dark mode background
                UIScrollView.appearance().verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -6)
            }
        }
        .sheet(isPresented: $showProfilePicker) {
            ProfileImagePicker(selectedImage: .constant(userDataManager.profilePicture), userDataManager: userDataManager)
        }
    }
    }
}

// Custom badge component
struct LabelBadge: View {
    var icon: String
    var text: String
    var color: Color
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(text)
                .font(.custom("Press Start 2P", size: 16))
                .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.1))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(15)
    }
}

// Achievement card component
struct AchievementCard: View {
    var icon: String
    var title: String
    var color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
                .frame(width: 60, height: 60)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            Text(title)
                .font(.custom("Press Start 2P", size: 14))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.1))
        }
        .frame(width: 110, height: 130)
        .padding(.vertical, 10)
        .background(Color(red: 0.87, green: 0.75, blue: 0.6))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 5)
    }
}

// the progress bar wasn't implemented correctly so had to change it
struct ProgressBar: View {
    var progress: CGFloat // from 0.0 to 1.0

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 20)

            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [.blue, .purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(width: progressBarWidth * progress, height: 20)
                .animation(.easeInOut(duration: 1.5), value: progress)
        }
    }

    private var progressBarWidth: CGFloat {
        UIScreen.main.bounds.width * 0.8
    }
}

struct ScrollingBackground: View {
    let imageName = "CaveBackground"
    @State private var offset: CGFloat = 0
    @State private var currentFrame = 0
    let imageWidth: CGFloat = 239 // adjust based on actual image width
    let stepCount: Int
    @State private var scrollTimer: Timer?
    @State private var frameTimer: Timer?
    @EnvironmentObject var userDataManager: UserDataManager

    var speed: CGFloat {
        return 25 + CGFloat(stepCount / 1000)
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(0..<6, id: \.self) { i in
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageWidth, height: 300)
                }
            }
            .offset(x: offset)
            .overlay(
                Image(selectedCharacterPrefix + String(currentFrame + 1))
                    .resizable()
                    .frame(width: 30, height: 45)
                    .position(x: 100, y: 230)
            )
            .onAppear {
                startTimers()
            }
            .onDisappear {
                scrollTimer?.invalidate()
                frameTimer?.invalidate()
            }
        }
        .frame(height: 300)
        .clipped()
    }

    private func startTimers() {
        scrollTimer?.invalidate()
        frameTimer?.invalidate()

        scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            offset -= speed * 0.01
            if offset <= -imageWidth * 3 {
                offset = 0
            }
        }

        frameTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            currentFrame = (currentFrame + 1) % 3
        }
    }

    private var selectedCharacterPrefix: String {
        if userDataManager.profilePicture.contains("LightBlue") {
            return "LightBlue"
        } else if userDataManager.profilePicture.contains("Blue") {
            return "Blue"
        } else if userDataManager.profilePicture.contains("Green") {
            return "Green"
        } else if userDataManager.profilePicture.contains("Orange") {
            return "Orange"
        } else if userDataManager.profilePicture.contains("Pink") {
            return "Pink"
        } else if userDataManager.profilePicture.contains("Purple") {
            return "Purple"
        } else if userDataManager.profilePicture.contains("Red") {
            return "Red"
        } else if userDataManager.profilePicture.contains("Yellow") {
            return "Yellow"
        } else {
            return "Blue"
        }
    }
}


#Preview {
    UserPage()
}

// If you use TabView in this file, apply accentColor to it and set Label foreground color for unselected state
// Example TabView usage:
/*
TabView {
    Label("Home", systemImage: "house")
        .foregroundColor(.white) // Unselected label color
        .tabItem {
            Label("Home", systemImage: "house")
        }
    Label("Profile", systemImage: "person")
        .foregroundColor(.white)
        .tabItem {
            Label("Profile", systemImage: "person")
        }
}
.accentColor(Color(red: 0.87, green: 0.75, blue: 0.6)) // Selected tab icon color
*/

struct CaveEntranceOverlay: View {
    @Binding var scale: CGFloat
    @Binding var showEntrance: Bool
    @State private var opacity: Double = 1.0

    var body: some View {
        ZStack {
            Image("CaveEntrance")
                .resizable()
                .scaledToFill()
                .scaleEffect(scale)
                .opacity(opacity)
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.easeInOut(duration: 2)) {
                        scale = 2.5
                        opacity = 0.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                        showEntrance = false
                    }
                }
        }
    }
}


struct ProfileImagePicker: View {
    @Binding var selectedImage: String
    @ObservedObject var userDataManager: UserDataManager
    @Environment(\.dismiss) var dismiss
    let imageNames = ["BlueProfile", "GreenProfile", "LightBlueProfile", "OrangeProfile", "PinkProfile", "PurpleProfile", "RedProfile", "YellowProfile"]

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack {
            Text("Choose a Profile Image")
                .font(.headline)
                .padding()
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(imageNames, id: \.self) { name in
                    Button(action: {
                        selectedImage = name
                        userDataManager.profilePicture = name
                        userDataManager.updateUserData(profileImageName: name)

                        userDataManager.fetchAllUsersForLeaderboard { profiles in
                            DispatchQueue.main.async {
                                userDataManager.globalLeaderboardData = profiles
                                userDataManager.objectWillChange.send()
                            }
                        }

                        dismiss()
                    }) {
                        Image(name)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 70, height: 70)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                }
            }
            .padding()
        }
    }
}
