import SwiftUI

/// List view of all entries grouped by date.
struct HistoryView: View {
    @ObservedObject var viewModel: StoolViewModel
    @State private var selectedEntry: StoolEntry?
    @State private var showEditSheet = false

    var body: some View {
        NavigationSplitView {
            historyList
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("History")
                            .font(.headline.weight(.bold))
                            .foregroundColor(Color.pdBrown)
                    }
                }
        } detail: {
            if let entry = selectedEntry {
                EditEntryView(viewModel: viewModel, entry: entry) {
                    selectedEntry = nil
                }
            } else {
                emptyDetailView
            }
        }
        .onAppear {
            viewModel.fetchAll()
        }
    }

    // MARK: - History List

    private var historyList: some View {
        Group {
            if viewModel.allEntries.isEmpty {
                emptyHistoryView
            } else {
                List {
                    ForEach(viewModel.entriesGroupedByDay, id: \.date) { group in
                        Section {
                            ForEach(group.entries, id: \.objectID) { entry in
                                Button {
                                    selectedEntry = entry
                                    showEditSheet = true
                                } label: {
                                    entryRow(entry)
                                }
                                .listRowBackground(Color.pdCardBackground)
                            }
                        } header: {
                            Text(formatSectionDate(group.date))
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(Color.pdBrown)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color.pdCream)
                .sheet(isPresented: $showEditSheet) {
                    if let entry = selectedEntry, !entry.isFault {
                        NavigationStack {
                            EditEntryView(viewModel: viewModel, entry: entry) {
                                showEditSheet = false
                                selectedEntry = nil
                            }
                        }
                    }
                }
            }
        }
    }

    private func entryRow(_ entry: StoolEntry) -> some View {
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
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.pdMint.opacity(0.3))
                    .cornerRadius(6)
            }

            Spacer()

            Text(entry.difficultyEnum.icon)
                .font(.system(size: 16))

            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundColor(Color.pdBrownLight)
        }
        .padding(.vertical, 4)
    }

    private func formatSectionDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMMM d"
            return formatter.string(from: date)
        }
    }

    // MARK: - Empty States

    private var emptyHistoryView: some View {
        VStack(spacing: 16) {
            Spacer()
            MascotView(
                message: "No entries yet! Start logging",
                imageName: "Pipi Sit Left",
                size: 100
            )
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pdCream)
    }

    private var emptyDetailView: some View {
        VStack(spacing: 16) {
            MascotView(
                message: "Select an entry to view details",
                imageName: "Pipi Sit Forward",
                size: 100
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pdCream)
    }
}

#Preview("History") {
    HistoryView(viewModel: StoolViewModel(context: CoreDataStack.preview.container.viewContext))
}
