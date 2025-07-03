//
//  SettingsView.swift
//  My Screen Diary
//
//  Created by 下平裕次郎 on R 7/06/30.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("SettingView")
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#F1F1E6").ignoresSafeArea())
    }
}
#Preview {
    SettingsView()
}
