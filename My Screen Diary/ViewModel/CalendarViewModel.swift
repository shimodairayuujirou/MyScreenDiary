import FirebaseAuth
import FirebaseFirestore
import Combine

class ContentViewModel: ObservableObject {
    private(set) var didSelectDateSubject: PassthroughSubject<DateComponents?, Never> = .init()
    private var cancellables: Set<AnyCancellable> = []

    @Published var selectedRecord: Record? = nil
    @Published var alertMessage: String? = nil
    @Published var showAlert = false
    @Published var showDetail: Bool = false

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

    private func showError(_ message: String) {
        self.alertMessage = message
        self.showAlert = true
    }
}
