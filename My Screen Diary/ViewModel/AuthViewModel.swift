import Foundation
import FirebaseAuth
import SwiftUI

class AuthViewModel: ObservableObject {
    @AppStorage("isAuthenticated") var isAuthenticated = false
    @Published var email = ""
    @Published var password = ""
    
    init() {
        checkAuthentication()
    }

    func checkAuthentication() {
        self.isAuthenticated = Auth.auth().currentUser != nil
    }

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("ログインエラー: \(error.localizedDescription)")
                return
            }
            self.isAuthenticated = true
        }
    }

    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("新規登録エラー: \(error.localizedDescription)")
                return
            }
            self.isAuthenticated = true
        }
    }

    func logout(appState: AppState) {
        do {
            try Auth.auth().signOut()
            self.isAuthenticated = false
            appState.rootViewId = UUID()
            print("ログアウト完了 - isAuthenticated: \(self.isAuthenticated)")
                    print("Auth.auth().currentUser: \(String(describing: Auth.auth().currentUser))")
        } catch {
            print("ログアウトエラー: \(error.localizedDescription)")
        }
    }
}

class AppState: ObservableObject {
    @Published var rootViewId = UUID()
}
