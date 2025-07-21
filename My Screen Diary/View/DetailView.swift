import SwiftUI

struct RecordDetailView: View {
    @StateObject private var viewModel = DetailViewModel()
    let record: Record

    var body: some View {
        VStack(spacing: 20) {
            Text("日付: \(viewModel.formattedDate(record.date))")
            Text("使用目的: \(record.purpose)")
            Text("満足度: \(Int(record.satisfaction))")
            Text("メモ: \(record.memo)")
            Text("使用時間: \(viewModel.formatDuration(minutes: record.durationMinutes))")
        }
        .padding()
        .navigationTitle("記録の詳細")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#F1F1E6").ignoresSafeArea())
    }
}
