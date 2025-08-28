import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showLogoutAlert = false
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Text("SettingView")
            Button("ログアウト") {
                showLogoutAlert = true
            }
            .foregroundColor(.red)
            .alert(isPresented: $showLogoutAlert) {
                Alert(
                    title: Text("確認"),
                    message: Text("ログアウトしますか？"),
                    primaryButton: .destructive(Text("ログアウト")) {
                        authViewModel.logout(appState: appState)
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#F1F1E6").ignoresSafeArea())
    }
}
#Preview {
    SettingsView()
}
