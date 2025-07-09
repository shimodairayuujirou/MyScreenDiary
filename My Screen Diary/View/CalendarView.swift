import SwiftUI
import Combine

struct CalendarView: View {
    @StateObject private var viewModel: ContentViewModel = .init()

    var body: some View {
        ZStack{
            VStack{
                UICalendarViewRepresentable(didSelectDateSubject: viewModel.didSelectDateSubject)
                            .padding(.bottom, 60)
            }
            .background(Color(hex: "#F1F1E6"))
            FloatingButton()
        }
        
    }
}

#Preview {
    CalendarView()
}
