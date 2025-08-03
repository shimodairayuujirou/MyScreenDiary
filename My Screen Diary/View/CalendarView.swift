import SwiftUI
import Combine

struct CalendarView: View {
    @StateObject private var viewModel: ContentViewModel = .init()
    @State private var showDetail = false

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    UICalendarViewRepresentable(didSelectDateSubject: viewModel.didSelectDateSubject)
                        .padding(.bottom, 60)
                        .alert(isPresented: $viewModel.showAlert) {
                            Alert(title: Text("エラー"),
                                  message: Text(viewModel.alertMessage ?? "不明なエラー"),
                                  dismissButton: .default(Text("OK")))
                        }
                }
                .background(Color(hex: "#F1F1E6"))

                FloatingButton()
            }
            //selectedRecordがセットされたら遷移
            .onChange(of: viewModel.selectedRecord) { oldValue, newValue in
                if newValue != nil {
                    showDetail = true
                }
            }
            .navigationDestination(isPresented: $viewModel.showDetail) {
                if let record = viewModel.selectedRecord {
                    RecordDetailView(
                        viewModel: DetailViewModel(record: record),
                    )
                }
            }
        }
    }
}
