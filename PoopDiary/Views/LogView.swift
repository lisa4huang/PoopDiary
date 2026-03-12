import SwiftUI

/// Interface for logging a new stool entry.
struct LogView: View {
    @ObservedObject var viewModel: StoolViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var dateTime = Date()
    @State private var bristolType: BristolType = .smoothSausage
    @State private var difficulty: Difficulty = .normal
    @State private var durationMinutes: Double = 5
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 5) {
                        // Header mascot
                        pipiImage("Pipi Sit Toilet")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 120)
                            .padding(.top, 8)

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
                    }

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
                                .frame(width: 50, alignment: .trailing)
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

                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
            .background(Color.pdCream.ignoresSafeArea())
            .navigationTitle("Log a Poop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color.pdBrown)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                    }
                    .font(.headline)
                    .foregroundColor(Color.pdBrown)
                }
            }
        }
    }

    private func saveEntry() {
        viewModel.addEntry(
            dateTime: dateTime,
            bristolType: bristolType,
            difficulty: difficulty,
            durationSeconds: Int32(durationMinutes * 60),
            notes: notes
        )
        dismiss()
    }
}

#Preview("Log Entry") {
    LogView(viewModel: StoolViewModel(context: CoreDataStack.preview.container.viewContext))
}
