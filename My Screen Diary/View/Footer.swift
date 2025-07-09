import SwiftUI

enum Page {
    case calendar, chart, settings
}

struct FooterMenuView: View {
    @Binding var selected: Page
    var body: some View {
        HStack {
            Spacer()
            Button(action: {selected = .calendar}) {
                Image(systemName: "calendar")
                    .font(.system(size: 25))
                    .foregroundStyle(Color(hex: "#EABE5A"))
            }
            Spacer()
            Button(action: {selected = .chart}) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 25))
                    .foregroundStyle(Color(hex: "#EABE5A"))
            }
            Spacer()
            Button(action: {selected = .settings}) {
                Image(systemName: "gearshape")
                    .font(.system(size: 25))
                    .foregroundStyle(Color(hex: "#EABE5A"))
            }
            Spacer()
        }
        .padding()
        .background(Color(hex: "#528261"))
    }
}

#Preview {
    FooterMenuView(selected: Binding.constant(.calendar))
}
