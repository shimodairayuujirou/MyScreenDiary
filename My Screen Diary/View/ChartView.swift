import SwiftUI
import Charts

struct DailyUsage: Identifiable {
    let id = UUID()
    let date: Date
    let minutes: Int
}

struct ChartView: View {
    @StateObject private var viewModel = ChartViewModel()
    @State private var selectedMode: String = "日ごと"
    @State private var selectedWeekIndex: Int = 0

    var body: some View {
        ZStack {
            VStack {
                // ヘッダー：切り替え
                Picker("表示モード", selection: $selectedMode) {
                    Text("日ごと").tag("日ごと")
                    Text("月平均").tag("月平均")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if selectedMode == "日ごと" {
                    if !viewModel.weeklyUsages.isEmpty {
                        dailyChartView(for: viewModel.weeklyUsages[selectedWeekIndex])
                    }
                } else {
                    Text("月平均ビュー（あとで実装）")
                }
                Spacer()
            }
            .padding()
            FloatingButton()
        }
        .background(Color(hex: "#F1F1E6").ignoresSafeArea())
        .onAppear {
            if let currentIndex = viewModel.currentWeekIndex {
                selectedWeekIndex = currentIndex
            }
        }
        .onChange(of: viewModel.currentWeekIndex) {
            if let newValue = viewModel.currentWeekIndex {
                selectedWeekIndex = newValue
            }
        }
    }

    // 日ごとのchartページ
    private func dailyChartView(for data: [DailyUsage]) -> some View {
        VStack(alignment: .leading) {
            Chart(data) { usage in
                BarMark(
                    x: .value("日付", usage.date, unit: .day),
                    y: .value("時間(分)", usage.minutes)
                )
                .foregroundStyle(Color(hex: "#528261"))
            }
            .chartXAxis {
                // 日ごとの目盛りを出す
                AxisMarks(values: .stride(by: .day, count: 1)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        // value から Date を取り出してフォーマットした Text を返す
                        if let date = value.as(Date.self) {
                            Text(Self.axisDateFormatter.string(from: date))
                                .foregroundStyle(.black)
                        }
                    }
                }
            }
            .chartYScale(domain: 0...dynamicMaxY(for: data))
            .chartYAxis {
                AxisMarks(values: Array(stride(from: 0, through: dynamicMaxY(for: data), by: 180))) { value in
                    if let minutes = value.as(Int.self) {
                        let hours = minutes / 60
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel("\(hours)時間")
                            .foregroundStyle(.black)
                    }
                }
            }
            .frame(height: 300)
            
            //週切り替え
            HStack {
                Button("＜ 前の週") {
                    if selectedWeekIndex > 0 {
                        selectedWeekIndex -= 1
                    }
                }
                .padding(8)
                .foregroundColor(Color(hex: "#F1F1E6"))
                .background(Color(hex: "#528261"))
                .cornerRadius(10)
                
                Spacer()
                Button("次の週 ＞") {
                    if selectedWeekIndex < viewModel.weeklyUsages.count - 1 {
                        selectedWeekIndex += 1
                    }
                }
                .padding(8)
                .foregroundColor(Color(hex: "#F1F1E6"))
                .background(Color(hex: "#528261"))
                .cornerRadius(10)
            }
            .padding()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("今週合計: \(data.totalMinutes / 60)時間 \(data.totalMinutes % 60)分")
                Text("1日平均: \(data.averageMinutesPerDay / 60)時間 \(data.averageMinutesPerDay % 60)分")
                if let ratio = viewModel.compareWithPreviousWeek(at: selectedWeekIndex) {
                        Text("先週比: \(ratio)%")
                }
            }
            .padding()
            .font(.subheadline)
        }
    }
    private func dynamicMaxY(for data: [DailyUsage]) -> Int {
        let maxMinutes = data.map { $0.minutes }.max() ?? 0
        let step = 180 // 3時間刻み
        let remainder = maxMinutes % step
        let adjusted = remainder == 0 ? maxMinutes : maxMinutes + (step - remainder)
        return max(adjusted, step)
    }
    
    // DateFormatter は毎回作らないよう一度だけ用意する（static 推奨）
    private static let axisDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "M/d" 
        f.locale = Locale(identifier: "ja_JP")
        f.timeZone = TimeZone.current
        return f
    }()
}
