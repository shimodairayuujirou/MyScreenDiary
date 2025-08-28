import SwiftUI

struct RecordDetailView: View {
    @ObservedObject var viewModel: DetailViewModel
    @Environment(\.dismiss) var dismiss
    
    let purposes = ["SNS", "動画", "ゲーム", "仕事", "その他"]
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("日時情報")) {
                    DatePicker("日付を選択", selection: Binding(
                        get: { viewModel.record.date },
                        set: { viewModel.record.date = $0 }
                    ),displayedComponents: [.date])
                    
                    DatePicker("使用時間", selection: Binding(
                        get: { viewModel.record.usetime },
                        set: { viewModel.record.usetime = $0 }
                    ),displayedComponents: [.hourAndMinute])
                    .datePickerStyle(.compact)
                }
                
                Section(header: Text("利用内容")) {
                    HStack{
                        Text("使用目的")
                        Spacer()
                        Menu {
                            ForEach(purposes, id: \.self) { purpose in
                                Button(action: {
                                    viewModel.record.purpose = purpose
                                }) {
                                    HStack {
                                        Text(purpose)
                                        Spacer()
                                        if viewModel.record.purpose == purpose {
                                            Image(systemName: "checkmark")
                                            .foregroundColor(.accentColor)
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(viewModel.record.purpose)
                                    .foregroundColor(.gray)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
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
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("記録情報")
                        .font(.headline)
                        .foregroundStyle(Color(hex: "#F1F1E6"))
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        viewModel.updateRecord { success in
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .foregroundColor(Color(hex: "#F1F1E6"))
                    .bold()
                }
            }
            .toolbarBackground(Color(hex: "#528261"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("エラー"),
                    message: Text(viewModel.alertMessage ?? "不明なエラー"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .background(Color(hex: "#F1F1E6"))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .hideKeyboardOnTap()
        .environment(\.locale, Locale(identifier: "ja_JP"))
        .environment(\.calendar, Calendar(identifier: .gregorian))
    }
}
