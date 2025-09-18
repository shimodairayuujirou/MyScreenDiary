import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class RecordViewModel: ObservableObject {
    @Published var record = Record()
    @Published var saveState: SaveState = .idle

    func saveRecord() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            saveState = .failure("ログイン情報を取得できませんでした")
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        let dateString = dateFormatter.string(from: record.date)
        let documentId = "\(userId)_\(dateString)"

        let db = Firestore.firestore()
        let docRef = db.collection("records").document(documentId)

        do {
            let snapshot = try await docRef.getDocument()
            if snapshot.exists {
                saveState = .failure("この日には既に記録があります")
                return
            }

            let data: [String: Any] = [
                "userId": userId,
                "date": record.date,
                "duration": record.durationMinutes,
                "purpose": record.purpose,
                "satisfaction": Int(record.satisfaction),
                "memo": record.memo
            ]

            try await docRef.setData(data)
            saveState = .success

        } catch {
            saveState = .failure("通信エラーが発生しました。もう一度お試しください")
            print("Firestore error:", error.localizedDescription)
        }
    }
}

enum SaveState: Equatable {
    case idle
    case saving
    case success
    case failure(String)

    static func == (lhs: SaveState, rhs: SaveState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.saving, .saving),
             (.success, .success):
            return true
        case (.failure(let lMsg), .failure(let rMsg)):
            return lMsg == rMsg
        default:
            return false
        }
    }
}
