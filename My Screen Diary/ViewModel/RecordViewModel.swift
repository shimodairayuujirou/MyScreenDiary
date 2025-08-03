import Foundation
import FirebaseFirestore
import FirebaseAuth

class RecordViewModel: ObservableObject {
    @Published var record = Record()
    @Published var alertMessage: String? = nil
    @Published var showAlert = false
    var onSaveSuccess: (() -> Void)?
    
    func saveRecord() {
        guard let userId = Auth.auth().currentUser?.uid else {
            alertMessage = "ユーザーIDが取得できませんでした"
            showAlert = true
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        let dateString = dateFormatter.string(from: record.date)
        let documentId = "\(userId)_\(dateString)"

        let db = Firestore.firestore()
        let docRef = db.collection("records").document(documentId)

        // 既に存在するか確認
        docRef.getDocument { snapshot, error in
            if let error = error {
                self.alertMessage = "取得失敗: \(error.localizedDescription)"
                self.showAlert = true
                return
            }

            if let snapshot = snapshot, snapshot.exists {
                self.alertMessage = "同じ日付の記録がすでに存在します"
                self.showAlert = true
                return
            }

            let data: [String: Any] = [
                "userId": userId,
                "date": self.record.date,
                "duration": self.record.durationMinutes,
                "purpose": self.record.purpose,
                "satisfaction": Int(self.record.satisfaction),
                "memo": self.record.memo
            ]

            docRef.setData(data) { error in
                if let error = error {
                    self.alertMessage = "保存失敗: \(error.localizedDescription)"
                    self.showAlert = true
                } else {
                    print("保存成功: \(data)")
                    self.onSaveSuccess?()
                }
            }
        }
    }
}
