import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("My Screen Diary")
                .foregroundColor(Color(hex: "#528261"))
                .font(.system(size: 45))
                .font(.title)
                .padding(.bottom, 10)
            TextField("メールアドレス", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)

            SecureField("パスワード", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                viewModel.login()
            }, label: {
                Text("ログイン")
                    .foregroundColor(Color(hex: "#EABE5A"))
                    .font(.system(size: 20))
                    .padding(10)
            })
                .background(Color(hex: "#528261"))
                .cornerRadius(5.0)
                .shadow(color: .gray, radius: 3, x: 3, y: 3)
            
            Button(action: {
                viewModel.register()
            }, label: {
                Text("新規登録")
                    .foregroundColor(Color(hex: "#528261"))
                    .font(.system(size: 20))
                    .padding(10)
            })
                .background(Color(hex: "#EABE5A"))
                .cornerRadius(5.0)
                .shadow(color: .gray, radius: 3, x: 3, y: 3)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#F1F1E6").ignoresSafeArea())
        .fullScreenCover(isPresented: $viewModel.isAuthenticated) {
            PageWrapperView()
        }
    }
}

