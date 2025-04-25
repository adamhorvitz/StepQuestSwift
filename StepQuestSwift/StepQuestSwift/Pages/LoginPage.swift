//
//  LoginPage.swift
//  StepQuestSwift
//
//  Created by Adam Horvitz on 3/7/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct LoginPage: View {
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isLoginMode = true
    @State private var errorMessage: String?
    @State private var showSplash = true
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreen(showSplash: $showSplash)
            } else {
                NavigationView {
                    ZStack {
                        Image("LoginBackground")
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()

                        VStack(spacing: 10) {
                            VStack(spacing: 15) {
                                Image("Logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 350, height: 350)
                                
                                Text(isLoginMode ? "Log in" : "Create Account")
                                    .font(.custom("Press Start 2P", size: 18))
                                    .foregroundColor(.white)
                                
                                Picker(selection: $isLoginMode, label:
                                        Text("Picker here")) {
                                    Text("Login")
                                        .tag(true)
                                    Text("Create Account")
                                        .tag(false)
                                }
                                .font(.custom("Press Start 2P", size: 12))
                                .pickerStyle(SegmentedPickerStyle())
                                .background(Color.white)
                                .cornerRadius(10)
                                .frame(maxWidth: 350)
                                .onChange(of: isLoginMode) {
                                    errorMessage = nil
                                }
                                if !isLoginMode {
                                    TextField("Name", text: $name)
                                        .font(.custom("Press Start 2P", size: 12))
                                        .autocapitalization(.words)
                                        .padding(12)
                                        .background(Color.white)
                                        .frame(maxWidth: 350)
                                        .foregroundColor(.black)
                                }
                                

                                TextField("Email", text: $email)
                                    .font(.custom("Press Start 2P", size: 12))
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .padding(12)
                                    .background(Color.white)
                                    .frame(maxWidth: 350)
                                    .foregroundColor(.black)
                                
                                SecureField("Password", text: $password)
                                    .font(.custom("Press Start 2P", size: 12))
                                    .padding(12)
                                    .background(Color.white)
                                    .frame(maxWidth: 350)
                                    .foregroundColor(.black)
                                
                                if let errorMessage = errorMessage {
                                    Text(errorMessage)
                                        .font(.custom("Press Start 2P", size: 12))
                                        .foregroundColor(.red)
                                        .multilineTextAlignment(.center)
                                }

                                
                                Button {
                                    handleAction()
                                } label: {
                                    HStack {
                                        Spacer()
                                        Text(isLoginMode ? "Log in" : "Create Account")
                                            .font(.custom("Press Start 2P", size: 14))
                                            .foregroundColor(.white)
                                            .padding(.vertical, 10)
                                        Spacer()
                                    }
                                    .frame(maxWidth: 350)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                }
                            }
                            .padding()
                        }
                        .frame(maxHeight: .infinity, alignment: .topLeading)
                        .animation(.none, value: isLoginMode)
                    }
                    .navigationTitle("")
                }
            }
        }
    }
    private func handleAction() {
        errorMessage = nil //clears old erros
        if isLoginMode {
            loginUser()
            print("Should log into Firebase with existing creditionals")
        } else {
            createNewAccount()
            print("Register a new account inside of Firebase Auth")
        }
    }

    private func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = "Wrong email or password."
                print("Failed to log in:", error.localizedDescription)
                return
            }
            print("Successfully logged in as: \(result?.user.uid ?? "")")

            guard let user = result?.user else { return }
            let uid = user.uid
            let docRef = Firestore.firestore().collection("users").document(uid)

            docRef.getDocument { document, error in
                if let document = document, document.exists {
                    print("User document already exists.")
                } else {
                    //update old users that didn't have data in firestore database yet
                    docRef.setData([
                        "name": "Name",
                        "weeklyGoal": 20000,
                        "rank": "Bronze",
                        "streak": 0,
                        "createdAt": Timestamp(date: Date()),
                        "email": user.email ?? "unknown"
                    ]) { error in
                        if let error = error {
                            print("Error creating user doc:", error.localizedDescription)
                        } else {
                            print("User document created for legacy user.")
                        }
                    }
                }
                authManager.isLoggedIn = true
            }
        }
    }
    
    private func createNewAccount() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .weakPassword:
                    self.errorMessage = "Password must be at least 6 characters."
                case .emailAlreadyInUse:
                    self.errorMessage = "This email is already in use."
                default:
                    self.errorMessage = "Account failed to create."
                }
                print("Create error:", error)
                return
            }
            
            guard let user = result?.user else { return }
            
            // Save to Firestore
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).setData([
                "name": name,
                "email": email,
                "createdAt": Timestamp(date: Date())
            ]) { err in
                if let err = err {
                    print("Error saving username to Firestore:", err.localizedDescription)
                } else {
                    print("Username saved to Firestore!")
                }
            }
            
            // Optional: set display name in Firebase Auth
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name
            changeRequest.commitChanges { error in
                if let error = error {
                    print("Failed to update display name:", error.localizedDescription)
                } else {
                    print("Display name updated to:", name)
                }
            }

            print("User created for: \(name)")
            authManager.isLoggedIn = true
        }
    }

}

struct SplashScreen: View {
    @Binding var showSplash: Bool
    @State private var showLogo = false
    @State private var fadeOut = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Welcome To:")
                    .font(.custom("Press Start 2P", size: 28))
                    .foregroundColor(.white)
                    .opacity(showLogo ? 1 : 0)

                if showLogo {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 350, height: 350)
                        .transition(.scale)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5)) {
                    showLogo = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation {
                        fadeOut = true
                    }
                }
            }
        }
        .opacity(fadeOut ? 0 : 1)
        .onChange(of: fadeOut) {
            if fadeOut {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        showSplash = false
                    }
                }
            }
        }
    }
}

struct ContentView_Preview1: PreviewProvider {
    static var previews: some View {
        LoginPage()
    }
}
