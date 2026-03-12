import SwiftUI

/// Segmented button picker for difficulty level.
struct DifficultyPicker: View {
    @Binding var selectedDifficulty: Difficulty

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Difficulty")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Color.pdBrown)

            HStack(spacing: 8) {
                ForEach(Difficulty.allCases) { diff in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            selectedDifficulty = diff
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text(diff.icon)
                                .font(.system(size: 22))
                            Text(diff.label)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(
                                    selectedDifficulty == diff ? .white : Color.pdBrown
                                )
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(backgroundColor(for: diff))
                        )
                        .scaleEffect(selectedDifficulty == diff ? 1.05 : 1.0)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func backgroundColor(for difficulty: Difficulty) -> Color {
        if selectedDifficulty == difficulty {
            switch difficulty {
            case .easy: return Color.pdEasy
            case .normal: return Color.pdNormal
            case .straining: return Color.pdStraining
            case .painful: return Color.pdPainful
            }
        } else {
            return Color.pdCardBackground
        }
    }
}

#Preview("Difficulty Picker") {
    struct Preview: View {
        @State var selected: Difficulty = .normal
        var body: some View {
            DifficultyPicker(selectedDifficulty: $selected)
                .padding()
                .background(Color.pdCream)
        }
    }
    return Preview()
}
