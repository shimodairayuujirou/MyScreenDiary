import FirebaseFirestore

extension Record {
    init(from data: [String: Any]) throws {
        let date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
        let purpose = data["purpose"] as? String ?? ""
        let satisfaction = data["satisfaction"] as? Double ?? 0
        let memo = data["memo"] as? String ?? ""
        let userId = data["userId"] as? String ?? ""
        let duration = data["duration"] as? Int ?? 0

        var calendar = Calendar.current
        calendar.timeZone = .current
        let hours = duration / 60
        let minutes = duration % 60
        let usetime = calendar.date(bySettingHour: hours, minute: minutes, second: 0, of: date) ?? date

        self.init(
            id: UUID().uuidString,
            userId: userId,
            date: date,
            usetime: usetime,
            purpose: purpose,
            satisfaction: satisfaction,
            memo: memo
        )
    }
}
