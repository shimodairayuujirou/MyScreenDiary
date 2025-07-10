import Foundation
import FirebaseAuth
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var email = ""
    @Published var password = ""
    
    init() {
        // アプリ起動時にログイン状態を確認
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

    func logout() {
        do {
            try Auth.auth().signOut()
            self.isAuthenticated = false
        } catch {
            print("ログアウトエラー: \(error.localizedDescription)")
        }
    }
}
