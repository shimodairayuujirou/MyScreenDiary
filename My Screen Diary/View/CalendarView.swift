import SwiftUI
import Combine

struct CalendarView: View {
    @StateObject private var viewModel: CalendarViewModel = .init()
    @State private var showDetail = false
    @State private var showAlert = false
    @State private var alertMessage: String? = nil
    @State private var selectedDateForNewRecord: Date? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    UICalendarViewRepresentable(
                        didSelectDateSubject: viewModel.didSelectDateSubject,
                        markedDates: viewModel.markedDates
                    )
                    .padding(.bottom, 60)
                    .onAppear {
                        Task{
                            await viewModel.fetchMarkedDates()
                        }
                    }
                    .onChange(of: viewModel.state) { _, newState in
                        switch newState {
                        case .error(let message):
                            alertMessage = message
                            showAlert = true
                        case .success:
                            showDetail = true
                        case .notFound(let date):
                            alertMessage = "この日に記録はありません。新しく作成してください"
                            showAlert = true
                            selectedDateForNewRecord = date
                        default:
                            break
                        }
                    }
                }
                .background(Color(hex: "#F1F1E6"))
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("エラー"),
                        message: Text(alertMessage ?? "不明なエラー"),
                        dismissButton: .default(Text("OK"))
                    )
                }

                FloatingButton()
            }
            // selectedRecord がセットされたら遷移
            .onChange(of: viewModel.selectedRecord) { _, newValue in
                if newValue != nil {
                    showDetail = true
                }
            }
            .navigationDestination(isPresented: $showDetail) {   // ← ここも View 側の State
                if let record = viewModel.selectedRecord {
                    RecordDetailView(
                        viewModel: DetailViewModel(record: record)
                    )
                }
            }
        }
    }
}
