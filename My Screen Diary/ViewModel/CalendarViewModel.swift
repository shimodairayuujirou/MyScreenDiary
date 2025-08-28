import FirebaseAuth
import FirebaseFirestore
import Combine

class CalendarViewModel: ObservableObject {
    
    let didSelectDateSubject = PassthroughSubject<DateComponents?, Never>()
    private var cancellables: Set<AnyCancellable> = []

    @Published var selectedRecord: Record? = nil
    @Published var alertMessage: String? = nil
    @Published var showAlert = false
    @Published var showDetail: Bool = false
    @Published var markedDates: [DateComponents] = []

    init() {
        subscribeDidSelectDate()
    }
    private func subscribeDidSelectDate() {
        didSelectDateSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dateComponents in
                guard let self = self else { return }

                guard var dateComponents = dateComponents else {
                    self.selectedRecord = nil
                    print("日付が選択されていません")
                    return
                }

                dateComponents.calendar = Calendar(identifier: .gregorian)
                dateComponents.timeZone = .current

                if let date = dateComponents.date {
                    self.fetchRecord(for: date)
                } else {
                    print("日付変換失敗")
                }
            }
            .store(in: &cancellables)
    }

    private func fetchRecord(for date: Date) {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.showError("ユーザーがログインしていません")
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.string(from: date)
        let documentId = "\(userId)_\(dateString)"

        let docRef = Firestore.firestore().collection("records").document(documentId)

        docRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                self.showError("取得失敗: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data() else {
                self.selectedRecord = nil
                print("この日に記録は存在しません")
                return
            }

            do {
                let record = try Record(from: data)
                self.selectedRecord = record
                self.showDetail = true
                print("取得成功: \(record)")
            } catch {
                self.showError("データの変換に失敗しました")
            }
        }
    }

    // 記録がある日をmarkedDatesに入れる
    func fetchMarkedDates() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore()
            .collection("records")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }

                if let docs = snapshot?.documents {
                    let calendar = Calendar(identifier: .gregorian)

                    self.markedDates = docs.compactMap { doc in
                        if let timestamp = doc.data()["date"] as? Timestamp {
                            let date = timestamp.dateValue()
                            let comps = calendar.dateComponents([.year, .month, .day], from: date)
                            print("📌 取得日: \(date) → comps: \(comps)")
                            return comps
                        }
                        return nil
                    }
                }
            }
    }


    private func showError(_ message: String) {
        self.alertMessage = message
        self.showAlert = true
    }
}
