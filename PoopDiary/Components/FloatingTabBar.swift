import SwiftUI

enum Tab: String, CaseIterable {
    case home = "house.fill"
    case history = "clock.fill"
    case stats = "chart.bar.fill"
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .history: return "History"
        case .stats: return "Stats"
        }
    }
}

struct FloatingTabBar: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        HStack(spacing: 30) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.rawValue)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(selectedTab == tab ? Color.pdBrown : Color.pdBrownLight.opacity(0.6))
                    }
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 18)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.95))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            Capsule()
                .stroke(Color.pdBrown.opacity(0.05), lineWidth: 0.5)
        )
    }
}

#Preview {
    ZStack {
        Color.pdCream.ignoresSafeArea()
        VStack {
            Spacer()
            FloatingTabBar(selectedTab: .constant(.home))
        }
    }
}
