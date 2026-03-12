import SwiftUI

/// Interface for editing or deleting stool entries.
struct EditEntryView: View {
    var viewModel: StoolViewModel
    let entry: StoolEntry
    var onDismiss: () -> Void

    @State private var dateTime: Date
    @State private var bristolType: BristolType
    @State private var difficulty: Difficulty
    @State private var durationMinutes: Double
    @State private var notes: String
    @State private var showDeleteConfirmation = false

    init(viewModel: StoolViewModel, entry: StoolEntry, onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self.entry = entry
        self.onDismiss = onDismiss

        _dateTime = State(initialValue: entry.dateTime)
        _bristolType = State(initialValue: entry.bristolTypeEnum)
        _difficulty = State(initialValue: entry.difficultyEnum)
        _durationMinutes = State(initialValue: Double(entry.durationSeconds) / 60.0)
        _notes = State(initialValue: entry.notes ?? "")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Time picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Time")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color.pdBrown)

                    DatePicker(
                        "Time",
                        selection: $dateTime,
                        in: ...Date(),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(Color.pdPeach)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .pdCard()

                // Bristol type selector
                BristolSelector(selectedType: $bristolType)
                    .pdCard()

                // Difficulty picker
                DifficultyPicker(selectedDifficulty: $difficulty)
                    .pdCard()

                // Duration slider
                VStack(alignment: .leading, spacing: 8) {
                    Text("How long did it take?")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color.pdBrown)

                    HStack {
                        Text("🕐")
                    Slider(value: $durationMinutes, in: 0...30, step: 1)
                        .tint(Color.pdMint)
                    Text(durationMinutes == 30 ? "30+m" : "\(Int(durationMinutes))m")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(Color.pdBrown)
                        .lineLimit(1)
                        .frame(width: 55, alignment: .trailing)
                        .fixedSize(horizontal: true, vertical: false)
                    }
                }
                .pdCard()

                // Notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes (optional)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color.pdBrown)

                    TextField("How was it?", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.pdPeach.opacity(0.5), lineWidth: 1)
                        )
                }
                .pdCard()

                // Delete button
                Button {
                    showDeleteConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Entry")
                    }
                }
                .buttonStyle(PDDeleteButtonStyle())
                .padding(.top, 8)

                Spacer(minLength: 20)
            }
            .padding(.horizontal)
        }
        .background(Color.pdCream.ignoresSafeArea())
        .navigationTitle("Edit Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    onDismiss()
                }
                .foregroundColor(Color.pdBrown)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveChanges()
                }
                .font(.headline)
                .foregroundColor(Color.pdBrown)
            }
        }
        .alert("Delete Entry?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteEntry()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This entry will be removed.")
        }
    }

    private func saveChanges() {
        viewModel.updateEntry(
            entry,
            dateTime: dateTime,
            bristolType: bristolType,
            difficulty: difficulty,
            durationSeconds: Int32(durationMinutes * 60),
            notes: notes
        )
        onDismiss()
    }

    private func deleteEntry() {
        // 1. Capture the ID we need to delete using safeID to avoid crashing
        let idToDelete = entry.safeID
        
        // 2. Dismiss the view immediately so it stops looking at the object
        onDismiss()
        
        // 3. Perform the actual deletion after a safe delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.deleteEntry(byId: idToDelete)
        }
    }
}
