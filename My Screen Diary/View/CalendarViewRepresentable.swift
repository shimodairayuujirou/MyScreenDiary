import SwiftUI
import Combine

struct UICalendarViewRepresentable: UIViewRepresentable {
    let didSelectDateSubject: PassthroughSubject<DateComponents?, Never>
    var markedDates: [DateComponents]

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        view.selectionBehavior = selection
        view.locale = Locale(identifier: "ja_JP")
        view.calendar = Calendar(identifier: .gregorian)
        view.delegate = context.coordinator
        return view
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        context.coordinator.markedDates = markedDates
        uiView.reloadDecorations(forDateComponents: markedDates, animated: false)
    }

    class Coordinator: NSObject, UICalendarSelectionSingleDateDelegate, UICalendarViewDelegate {
        private let parent: UICalendarViewRepresentable
        var markedDates: [DateComponents] = []

        init(_ parent: UICalendarViewRepresentable) {
            self.parent = parent
        }

        // 日付タップ処理
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            parent.didSelectDateSubject.send(dateComponents)
            selection.setSelected(nil, animated: false)
        }

        // カレンダーデコレーション
        func calendarView(_ calendarView: UICalendarView,
                          decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            if markedDates.contains(where: { $0.year == dateComponents.year &&
                                             $0.month == dateComponents.month &&
                                             $0.day == dateComponents.day })
            {
                return .customView {
                    let rectView = UIView()
                    rectView.backgroundColor = UIColor(red: 82/255, green: 130/255, blue: 97/255, alpha: 1.0)
                    rectView.layer.cornerRadius = 6
                    rectView.clipsToBounds = true

                    rectView.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        rectView.widthAnchor.constraint(equalToConstant: 50),
                        rectView.heightAnchor.constraint(equalToConstant: 16)
                    ])

                    return rectView
                }
            }
            return nil
        }
    }
}
