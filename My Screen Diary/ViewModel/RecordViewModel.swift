import Foundation
import FirebaseFirestore

class RecordViewModel: ObservableObject {
    @Published var record = Record()

    func saveRecord() {
        let db = Firestore.firestore()

        let data: [String: Any] = [
            "date": record.date,
            "duration": record.durationMinutes,
            "purpose": record.purpose,
            "satisfaction": Int(record.satisfaction),
            "memo": record.memo
        ]

        db.collection("records").document(record.id).setData(data) { error in
            if let error = error {
                print("保存失敗: \(error.localizedDescription)")
            } else {
                print("保存成功: \(data)")
            }
        }
    }
}
