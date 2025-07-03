//
//  RecordSheet.swift
//  My Screen Diary
//
//  Created by 下平裕次郎 on R 7/07/02.
//
import SwiftUI

struct RecordSheetView: View {
    @Environment(\.dismiss) var dismiss

    @State private var selectedDate = Date()
    @State private var usageTime = Date()
    @State private var selectedPurpose = "SNS"
    @State private var satisfaction = 4.0
    @State private var memo = ""

    let purposes = ["SNS", "動画", "ゲーム", "仕事", "その他"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("キャンセル") {
                    print("キャンセルしました")
                    dismiss()
                }
                .foregroundColor(Color(hex: "#F1F1E6"))
                .bold()
                Spacer()
                Button("保存") {
                    print("保存しました")
                    dismiss()
                }
                .foregroundColor(Color(hex: "#F1F1E6"))
                .bold()
            }
            .padding()
            .background(Color(hex: "#528261"))

            Form {
                Section(header: Text("日時情報")) {
                    DatePicker("日付を選択", selection: $selectedDate, displayedComponents: [.date])
                    
                    DatePicker("使用時間", selection: $usageTime, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(.compact)
                }
                
                Section(header: Text("利用内容")) {
                    Picker("使用目的", selection: $selectedPurpose) {
                        ForEach(purposes, id: \.self) {
                            Text($0)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("スマホ使用満足度")
                        Slider(value: $satisfaction, in: 1...7, step: 1)
                    }
                }

                Section(header: Text("一言メモ")) {
                    TextEditor(text: $memo)
                        .frame(height: 100)
                        .background(Color.white)
                        .cornerRadius(8)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .background(Color(hex: "#F1F1E6"))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    RecordSheetView()
}
