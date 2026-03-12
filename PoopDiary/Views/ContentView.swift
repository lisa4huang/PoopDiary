import SwiftUI
import CoreData

/// Root view with tab navigation and global log action.
struct ContentView: View {
    @StateObject private var viewModel: StoolViewModel
    @State private var selectedTab: Tab = .home
    @State private var showLogSheet = false

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: StoolViewModel(context: context))
    }

    var body: some View {
        ZStack {
            // Content
            TabView(selection: $selectedTab) {
                HomeView(viewModel: viewModel, onLogTap: { showLogSheet = true })
                    .tag(Tab.home)
                
                HistoryView(viewModel: viewModel)
                    .tag(Tab.history)
                
                StatsView(viewModel: viewModel)
                    .tag(Tab.stats)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Floating Bottom Bar and Action Button
            VStack {
                Spacer()
                
                HStack(spacing: 40) {
                    FloatingTabBar(selectedTab: $selectedTab)
                    
                    Button {
                        showLogSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.pdPink)
                            .clipShape(Circle())
                            .shadow(color: Color.pdPink.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }
        }
        .background(Color.pdCream.ignoresSafeArea())
        .sheet(isPresented: $showLogSheet) {
            LogView(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView(context: CoreDataStack.preview.container.viewContext)
}
