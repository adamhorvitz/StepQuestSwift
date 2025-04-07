//
//  UserPage.swift
//  StepQuestSwift
//
//  Created by Adam Horvitz on 3/7/25.
//

import SwiftUI

struct UserPage: View {
    @State private var username: String = "Adam Horvitz"
    @State private var stepCount: Int = 50000
    @State private var rank: String = "Gold"
    @State private var streak: Int = 7
    @State private var animatedProgress: CGFloat = 0.0
    @StateObject var healthManager = HealthManager()

    
    // Define gradient colors
    private let goldGradient = LinearGradient(
        gradient: Gradient(colors: [Color.yellow, Color.orange.opacity(0.7)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Calculate percentage of weekly goal (assuming 70,000 steps/week goal)
    private var progressPercentage: CGFloat {
        min(CGFloat(stepCount) / 70000.0, 1.0)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]),
                              startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    // Profile section with custom styling
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        VStack(spacing: 15) {
                            // Avatar with gold border for high rank
                            ZStack {
                                Circle()
                                    .fill(goldGradient)
                                    .frame(width: 115, height: 115)
                                
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.white)
                                    .background(Color.gray.clipShape(Circle()))
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                            
                            Text(username)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                            
                            // Badge row
                            HStack(spacing: 15) {
                                LabelBadge(icon: "crown.fill", text: rank, color: .yellow)
                                LabelBadge(icon: "flame.fill", text: "\(streak) days", color: .red)
                            }
                        }
                    }
                    .padding(.top, 10)
                    .frame(height: 250)
                    .padding(.horizontal)
                    
                    // Stats section
                    VStack(spacing: 15) {
                        Text("Weekly Progress")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                        
                        // Animated progress bar
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 25)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(LinearGradient(gradient: Gradient(colors: [.blue, .purple]),
                                                     startPoint: .leading, endPoint: .trailing))
                                .frame(width: UIScreen.main.bounds.width * 0.8 * animatedProgress, height: 25)
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.8)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.5)) {
                                animatedProgress = progressPercentage
                            }
                        }
                        
                        // Step count display
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(stepCount)")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(.blue)
                                
                                Text("steps this week")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            // Target display
                            VStack(alignment: .trailing) {
                                Text("70,000")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundColor(.gray.opacity(0.8))
                                
                                Text("weekly goal")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal)
                    
                    // Achievements section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Recent Achievements")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .padding(.horizontal)
//                        ScrollView(.horizontal) {
                            HStack(spacing: 15) {
                                AchievementCard(icon: "flame.fill", title: "7-Day Streak", color: .red)
                                AchievementCard(icon: "figure.walk", title: "50K Steps", color: .blue)
                                AchievementCard(icon: "star.fill", title: "Gold Status", color: .yellow)
                            }
                            .padding(.horizontal)
//                        }
                    }
                    .padding(.top)
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("User Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.blue)
                    }
                }
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
                .font(.system(size: 16, weight: .semibold, design: .rounded))
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
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
        }
        .frame(width: 110, height: 130)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
}

#Preview {
    UserPage()
}
