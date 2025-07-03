//
//  PageWrapperView.swift
//  My Screen Diary
//
//  Created by 下平裕次郎 on R 7/06/30.
//

import SwiftUI

struct PageWrapperView: View {
    @State private var selectedPage: Page = .calendar

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedPage {
                case .calendar:
                    CalendarView()
                case .chart:
                    ChartView()
                case .settings:
                    SettingsView()
                }
            }
            FooterMenuView(selected: $selectedPage)
        }
    }
}

#Preview {
    PageWrapperView()
}
