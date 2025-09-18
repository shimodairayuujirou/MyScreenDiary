import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class CalendarViewModel: ObservableObject {
    let didSelectDateSubject = PassthroughSubject<DateComponents?, Never>()
    private var cancellables: Set<AnyCancellable> = []

    @Published var selectedRecord: Record? = nil
    @Published var markedDates: [DateComponents] = []
    @Published var state: CalendarState = .idle

    init() {
        subscribeDidSelectDate()
    }

    private func subscribeDidSelectDate() {
        didSelectDateSubject
            .sink { [weak self] dateComponents in
                guard let self = self else { return }

                guard var dateComponents = dateComponents else {
                    self.selectedRecord = nil
                    self.state = .idle
                    print("日付が選択されていません")
                    return
                }

                dateComponents.calendar = Calendar(identifier: .gregorian)
                dateComponents.timeZone = .current

                if let date = dateComponents.date {
                    Task {
                        await self.fetchRecord(for: date)
                    }
                } else {
                    self.state = .error("日付変換失敗")
                }
            }
            .store(in: &cancellables)
    }

    func fetchRecord(for date: Date) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.state = .error("ユーザーがログインしていません")
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.string(from: date)
        let documentId = "\(userId)_\(dateString)"

        let docRef = Firestore.firestore().collection("records").document(documentId)

        state = .loading
        do {
            let snapshot = try await docRef.getDocument()
            guard let data = snapshot.data() else {
                self.selectedRecord = nil
                self.state = .notFound(date)
                return
            }

            let record = try Record(from: data)
            self.selectedRecord = record
            self.state = .success(record)
        } catch {
            self.state = .error("取得失敗: \(error.localizedDescription)")
        }
    }

    // 記録がある日をmarkedDatesに入れる
    func fetchMarkedDates() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        do {
            let snapshot = try await Firestore.firestore()
                .collection("records")
                .whereField("userId", isEqualTo: userId)
                .getDocuments()

            let calendar = Calendar(identifier: .gregorian)
            self.markedDates = snapshot.documents.compactMap { doc in
                if let timestamp = doc.data()["date"] as? Timestamp {
                    let date = timestamp.dateValue()
                    return calendar.dateComponents([.year, .month, .day], from: date)
                }
                return nil
            }
        } catch {
            print("取得失敗: \(error.localizedDescription)")
        }
    }
}


enum CalendarState: Equatable {
    case idle
    case loading
    case success(Record)
    case notFound(Date)
    case error(String)

    static func == (lhs: CalendarState, rhs: CalendarState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.loading, .loading):
            return true
        case (.success, .success): // Record の中身までは比較しない
            return true
        case (.notFound, .notFound):
            return true
        case (.error(let lMsg), .error(let rMsg)):
            return lMsg == rMsg
        default:
            return false
        }
    }
}
