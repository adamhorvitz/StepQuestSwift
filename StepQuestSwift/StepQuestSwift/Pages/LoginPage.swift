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
    @State private var isLoginMode = false
    @State private var errorMessage: String?
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing:20) {
                    Picker(selection: $isLoginMode, label:
                            Text("Picker here")) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                        .onChange(of: isLoginMode) {
                            errorMessage = nil
                        }
                    
                    if !isLoginMode {
                        TextField("Name", text: $name)
                            .autocapitalization(.words)
                            .padding(12)
                            .background(Color.white)
                    }

                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(12)
                        .background(Color.white)
                    
                    SecureField("Password", text: $password)
                        .padding(12)
                        .background(Color.white)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    
                    Button {
                        handleAction()
                    } label: {
                        HStack {
                            Spacer()
                            Text(isLoginMode ? "Log in" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 20, weight: .semibold))
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle(isLoginMode ? "Log in" : "Create Account")
            .background(Color(.init(white:0, alpha: 0.05))
                .ignoresSafeArea())
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
                    //update old users that didn't have data in firestore database
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

struct ContentView_Preview1: PreviewProvider {
    static var previews: some View {
        LoginPage()
    }
}
