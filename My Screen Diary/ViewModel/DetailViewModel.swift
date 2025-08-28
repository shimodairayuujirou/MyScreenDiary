import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class DetailViewModel: ObservableObject {
    @Published var record: Record
    @Published var showAlert: Bool = false
    @Published var alertMessage: String? = nil

    init(record: Record) {
        self.record = record
    }
    
    func updateRecord(completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.alertMessage = "ユーザーIDが取得できませんでした"
            self.showAlert = true
            completion(false)
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        let dateString = dateFormatter.string(from: record.date)
        let documentId = "\(userId)_\(dateString)"

        let db = Firestore.firestore()
        let data: [String: Any] = [
            "userId": userId,
            "date": record.date,
            "duration": record.durationMinutes,
            "purpose": record.purpose,
            "satisfaction": Int(record.satisfaction),
            "memo": record.memo
        ]

        db.collection("records").document(documentId).updateData(data) { error in
            if let error = error {
                self.alertMessage = "更新失敗: \(error.localizedDescription)"
                self.showAlert = true
                completion(false)
            } else {
                print("更新成功: \(data)")
                completion(true)
            }
        }
    }

}
