import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("isAuthenticated") var isAuthenticated = false

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                PageWrapperView()
                    .ignoresSafeArea(.keyboard)
            } else {
                AuthView()
            }
        }
        .onAppear {
            print("RootView onAppear - isAuthenticated: \(authViewModel.isAuthenticated)")
                    authViewModel.checkAuthentication()
                }
    }
}
