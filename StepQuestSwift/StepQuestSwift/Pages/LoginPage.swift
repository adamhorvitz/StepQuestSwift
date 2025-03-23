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
    @State private var isLoginMode = false
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
                    
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(12)
                        .background(Color.white)
                    
                    SecureField("Password", text: $password)
                        .padding(12)
                        .background(Color.white)
                    
                    
                    Button {
                        handleAction()
                        authManager.isLoggedIn = true
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
                print("Failed to log in:", error)
                return
            }
            print("Successfully logged in as: \(result?.user.uid ?? "")")
        }
    }
    
    private func createNewAccount() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Failed to create user:", error)
                return
            }
            print("Successfully created user: \(result?.user.uid ?? "")")
        }
    }
}

struct ContentView_Preview1: PreviewProvider {
    static var previews: some View {
        LoginPage()
    }
}

//#Preview {
//    LoginPage()
//}
