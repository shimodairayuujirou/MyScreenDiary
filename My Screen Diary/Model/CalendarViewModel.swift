//
//  CalendarViewModel.swift
//  My Screen Diary
//
//  Created by 下平裕次郎 on R 7/07/02.
//
import SwiftUI
import Combine

class ContentViewModel: ObservableObject {
    private(set) var didSelectDateSubject: PassthroughSubject<DateComponents?, Never> = .init()
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        subscribeDidSelectDate()
    }
    
    private func subscribeDidSelectDate() {
        didSelectDateSubject
            .receive(on: DispatchQueue.main)
            .sink { dateComponents in
                if let dateComponents = dateComponents {
                    var calendar = Calendar.current
                    calendar.timeZone = TimeZone.current// 明示的に設定（必要なら .autoupdatingCurrent も）
                    
                    if let date = calendar.date(from: dateComponents) {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy/MM/dd"
                        formatter.timeZone = TimeZone.current  // ローカルタイムに合わせる

                        print("選択された日付: \(formatter.string(from: date))")
                    }
                    
                } else {
                    print("日付が選択されていません")
                }
            }
            .store(in: &cancellables)
    }
}
