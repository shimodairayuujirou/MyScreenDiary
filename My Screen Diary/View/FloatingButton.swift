//
//  FloatingButton.swift
//  My Screen Diary
//
//  Created by 下平裕次郎 on R 7/07/02.
//

import SwiftUI

struct FloatingButton: View {
    @State var showSheet: Bool = false
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    print("スマホ使用時間記録ボタン")
                    showSheet.toggle()
                }, label: {
                    Image(systemName: "iphone.slash")
                        .foregroundColor(Color(hex: "#EABE5A"))
                        .font(.system(size: 30))
                })
                    .frame(width: 70, height: 70)
                    .background(Color(hex: "#528261"))
                    .cornerRadius(50.0)
                    .shadow(color: .gray, radius: 3, x: 3, y: 3)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 16.0, trailing: 16.0))
                    .sheet(isPresented: $showSheet) {RecordSheetView()}
            }
        }
    }
}
#Preview {
    FloatingButton()
}
