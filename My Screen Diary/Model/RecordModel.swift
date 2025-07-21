import Foundation

struct Record: Identifiable, Codable, Equatable{
    var id: String = UUID().uuidString
    var userId: String = ""
    var date: Date = Date()
    var usetime: Date = Date() // View用の一時的なDate型
    var purpose: String = "SNS"
    var satisfaction: Double = 4
    var memo: String = ""
    
    //Firestoreに保存する値として、usetimeの duration（分）を返す
    var durationMinutes: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: usetime)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }
}
