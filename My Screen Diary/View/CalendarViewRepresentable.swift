//
//  CalendarViewRepresentable.swift
//  My Screen Diary
//
//  Created by 下平裕次郎 on R 7/07/02.
//
import SwiftUI
import Combine

struct UICalendarViewRepresentable: UIViewRepresentable {
    private let didSelectDateSubject: PassthroughSubject<DateComponents?, Never>
    
    init(didSelectDateSubject: PassthroughSubject<DateComponents?, Never>) {
        self.didSelectDateSubject = didSelectDateSubject
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        view.selectionBehavior = selection
        return view
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {}

    class Coordinator: NSObject, UICalendarSelectionSingleDateDelegate {
        private let parent: UICalendarViewRepresentable

        init(_ parent: UICalendarViewRepresentable) {
            self.parent = parent
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            parent.didSelectDateSubject.send(dateComponents)
        }
    }
}
