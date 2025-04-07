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
        //i think its this function that not correctly checking if the password is in database so if u use wrong password it still logs u in
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = "Wrong email or password."
                print("Failed to log in:", error.localizedDescription)
                return
            }
            print("Successfully logged in as: \(result?.user.uid ?? "")")
            authManager.isLoggedIn = true
            
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

            print("User created: \(result?.user.uid ?? "")")
            authManager.isLoggedIn = true
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
