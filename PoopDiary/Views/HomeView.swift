import SwiftUI

/// Main dashboard showing daily summary and logs.
struct HomeView: View {
    @ObservedObject var viewModel: StoolViewModel
    var onLogTap: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: -10) {
                        pipiImage("Pipi Sit Forward")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 180)
                            .zIndex(1)

                        Button {
                            onLogTap()
                        } label: {
                            Text("LOG NEW POOP")
                        }
                        .buttonStyle(PDPrimaryButtonStyle())
                    }
                    .padding(.top, 20)

                    // Daily Summary
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Today")
                            .font(.headline)
                            .foregroundColor(Color.pdBrown)
                        
                        VStack(spacing: 0) {
                            Text("TODAY'S PROGRESS")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color.pdBrownLight)
                                .padding(.bottom, 16)
                            
                            HStack(spacing: 12) {
                                progressPill(
                                    icon: pooImage("Poo"),
                                    value: "\(viewModel.todayEntries.count) Logs",
                                    color: Color.pdPeach
                                )
                                
                                progressPill(
                                    icon: Image(systemName: "clock.fill"),
                                    value: "Last:\n\(viewModel.lastEntryTime)",
                                    color: Color.pdPeach
                                )
                                
                                progressPill(
                                    icon: Image(systemName: "flame.fill"),
                                    value: "\(viewModel.streakCount) DAY\nSTREAK",
                                    color: Color.pdPeach
                                )
                            }
                        }
                        .padding(.vertical, 24)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.pdBrown.opacity(0.05), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)

                    // Recent entries
                    if !viewModel.todayEntries.isEmpty {
                        recentEntriesList
                            .padding(.horizontal)
                    }

                    Spacer(minLength: 40)
                }
            }
            .background(Color.pdCream.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Poop Diary")
                        .font(.headline.weight(.bold))
                        .foregroundColor(Color.pdBrown)
                }
            }
            .onAppear {
                viewModel.fetchAll()
            }
        }
    }

    private func progressPill(icon: Image, value: String, color: Color) -> some View {
        HStack(spacing: 8) {
            icon
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18)
                .foregroundColor(Color.pdBrown)
            
            Text(value)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color.pdBrown)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, minHeight: 25)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Capsule().fill(color.opacity(0.7)))
    }

    private var recentEntriesList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Logs")
                .font(.headline)
                .foregroundColor(Color.pdBrown)
                .padding(.horizontal, 4)

            ForEach(viewModel.todayEntries) { entry in
                recentEntryRow(entry)
            }
        }
    }

    private func recentEntryRow(_ entry: StoolEntry) -> some View {
        HStack(spacing: 12) {
            Text(entry.formattedTime)
                .font(.subheadline.weight(.medium))
                .foregroundColor(Color.pdBrown)
                .frame(width: 80, alignment: .leading)

            PoopIconView(bristolType: entry.bristolTypeEnum, size: 22)

            if entry.durationSeconds > 0 {
                Text(entry.formattedDuration)
                    .font(.caption)
                    .foregroundColor(Color.pdBrownLight)
            }

            Spacer()

            Text(entry.difficultyEnum.icon)
                .font(.system(size: 16))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.pdBrown.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview("Home") {
    HomeView(viewModel: StoolViewModel(context: CoreDataStack.preview.container.viewContext), onLogTap: {})
}
