import SwiftUI

class DetailViewModel: ObservableObject {
    @Published var record: Record

    init(record: Record) {
        self.record = record
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    func formatDuration(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)時間\(mins)分"
        } else {
            return "\(mins)分"
        }
    }
}
