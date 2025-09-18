import SwiftUI

struct RecordSheetView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = RecordViewModel()

    let purposes = ["SNS", "動画", "ゲーム", "仕事", "その他"]

    var body: some View {
        VStack {
            HStack {
                Button("キャンセル") {
                    print("キャンセルしました")
                    dismiss()
                }
                .foregroundColor(Color(hex: "#F1F1E6"))
                .bold()
                Spacer()
                Button("保存") {
                    Task {
                        await viewModel.saveRecord()
                    }
                }
                .alert(isPresented: Binding<Bool>(
                    get: {
                        if case .failure(_) = viewModel.saveState { return true }
                        return false
                    },
                    set: { _ in viewModel.saveState = .idle }
                )) {
                    if case .failure(let message) = viewModel.saveState {
                        return Alert(
                            title: Text("エラー"),
                            message: Text(message),
                            dismissButton: .default(Text("OK"))
                        )
                    } else {
                        return Alert(title: Text("エラー"))
                    }
                }
                .onChange(of: viewModel.saveState) { oldValue, newValue in
                    if case .success = newValue {
                        dismiss()
                        viewModel.saveState = .idle
                    }
                }
                .foregroundColor(Color(hex: "#F1F1E6"))
                .bold()
            }
            .padding()
            .background(Color(hex: "#528261"))

            Form {
                Section(header: Text("日時情報")) {
                    DatePicker("日付を選択", selection: $viewModel.record.date, displayedComponents: [.date])
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                        .environment(\.calendar, Calendar(identifier: .gregorian))
                    DatePicker("使用時間", selection: $viewModel.record.usetime, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(.compact)
                }
                
                Section(header: Text("利用内容")) {
                    Picker("使用目的", selection: $viewModel.record.purpose) {
                        ForEach(purposes, id: \.self) {
                            Text($0)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("スマホ使用満足度")
                        Slider(value: $viewModel.record.satisfaction, in: 1...7, step: 1)
                    }
                }

                Section(header: Text("一言メモ")) {
                    TextEditor(text: $viewModel.record.memo)
                        .frame(height: 105)
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
