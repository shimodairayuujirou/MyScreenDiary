import Foundation
import FirebaseFirestore

class ChartViewModel: ObservableObject {
    @Published var dailyUsages: [DailyUsage] = []
    @Published var weeklyUsages: [[DailyUsage]] = []
    @Published var currentWeekIndex: Int?

    private var db = Firestore.firestore()

    init() {
        fetchData()
    }

    func fetchData() {
        db.collection("records")
            .order(by: "date", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Firestore error: \(error)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                let usages: [DailyUsage] = documents.compactMap { doc in
                    guard let date = (doc["date"] as? Timestamp)?.dateValue(),
                          let minutes = doc["duration"] as? Int else {
                        return nil
                    }
                    return DailyUsage(date: date, minutes: minutes)
                }

                DispatchQueue.main.async {
                    self.dailyUsages = usages
                    let (weeks, latestIndex) = self.generateWeeklyUsages(from: usages)
                    self.weeklyUsages = weeks
                    self.currentWeekIndex = latestIndex
                }
            }
    }

    // 強制的に日曜始まりにする関数
    private func startOfWeek(for date: Date) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1 // 日曜始まりに固定

        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components)!
    }

    func generateWeeklyUsages(from allData: [DailyUsage]) -> ([[DailyUsage]], Int) {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ja_JP")
        calendar.firstWeekday = 1 // 日曜

        guard let minDate = allData.map({ $0.date }).min(),
              let maxDate = allData.map({ $0.date }).max() else {
            return ([], 0)
        }

        // 強制的に日曜始まりで範囲を計算
        var currentWeekStart = startOfWeek(for: minDate)
        let endOfWeek = startOfWeek(for: maxDate)

        var weeks: [[DailyUsage]] = []
        var index = 0
        var latestIndex = 0

        while currentWeekStart <= endOfWeek {
            let weekData = completeWeekData(for: currentWeekStart, data: allData)
            weeks.append(weekData)

            // 最新の週をインデックスとして保持（maxDateを含む週）
            if maxDate >= currentWeekStart,
               maxDate < calendar.date(byAdding: .day, value: 7, to: currentWeekStart)! {
                latestIndex = index
            }

            currentWeekStart = calendar.date(byAdding: .day, value: 7, to: currentWeekStart)!
            index += 1
        }

        return (weeks, latestIndex)
    }

    private func completeWeekData(for weekStart: Date, data: [DailyUsage]) -> [DailyUsage] {
        let calendar = Calendar.current
        var completed: [DailyUsage] = []

        for offset in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: offset, to: weekStart) {
                if let existing = data.first(where: { calendar.isDate($0.date, inSameDayAs: day) }) {
                    completed.append(existing)
                } else {
                    completed.append(DailyUsage(date: day, minutes: 0))
                }
            }
        }
        return completed
    }
    
    // 今週と先週の比率を計算する（%）
    func compareWithPreviousWeek(at index: Int) -> Int? {
        guard index > 0,
              index < weeklyUsages.count else { return nil }
        
        let thisWeek = weeklyUsages[index].totalMinutes
        let lastWeek = weeklyUsages[index - 1].totalMinutes
        
        guard lastWeek > 0 else { return nil } // ゼロ除算防止
        
        return Int(Double(thisWeek) / Double(lastWeek) * 100)
    }
}

extension Array where Element == DailyUsage {
    /// 週の合計時間（分）
    var totalMinutes: Int {
        self.map { $0.minutes }.reduce(0, +)
    }
    
    /// 週の平均使用時間（分）
    var averageMinutesPerDay: Int {
        guard !self.isEmpty else { return 0 }
        return totalMinutes / self.count
    }
}
