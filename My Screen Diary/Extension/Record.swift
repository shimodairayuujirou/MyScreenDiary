import FirebaseFirestore

//extension Record {
//    init(from data: [String: Any]) throws {
//        guard let date = (data["date"] as? Timestamp)?.dateValue(),
//              let userId = data["userId"] as? String,
//              let duration = data["duration"] as? Int,
//              let purpose = data["purpose"] as? String,
//              let satisfaction = data["satisfaction"] as? Int,
//              let memo = data["memo"] as? String else {
//            throw NSError(domain: "RecordParsing", code: -1, userInfo: [NSLocalizedDescriptionKey: "Recordのデータ変換に失敗"])
//        }
//
//        // duration（分）を Date に変換（usetime に一時的に格納）
//        let calendar = Calendar.current
//        let now = Date()
//        let hour = duration / 60
//        let minute = duration % 60
//        let usetime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now) ?? now
//
//        self.id = UUID().uuidString
//        self.userId = userId
//        self.date = date
//        self.usetime = usetime
//        self.purpose = purpose
//        self.satisfaction = Double(satisfaction)
//        self.memo = memo
//    }
//}

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
