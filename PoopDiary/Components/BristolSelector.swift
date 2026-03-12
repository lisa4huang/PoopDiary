import SwiftUI

/// Horizontal row of 7 selectable Bristol stool type icons.
struct BristolSelector: View {
    @Binding var selectedType: BristolType

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Stool Type")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Color.pdBrown)

            HStack(spacing: 6) {
                ForEach(BristolType.allCases) { type in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            selectedType = type
                        }
                    } label: {
                        VStack(spacing: 4) {
                            bristolIconImage(type.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 28, height: 28)
                            Text(type.typeNumber)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(
                                    selectedType == type ? Color.pdBrown : Color.pdBrownLight
                                )
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    selectedType == type
                                        ? Color.pdPeach.opacity(0.5)
                                        : Color.clear
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    selectedType == type
                                        ? Color.pdPeach
                                        : Color.clear,
                                    lineWidth: 2
                                )
                        )
                        .scaleEffect(selectedType == type ? 1.05 : 1.0)
                    }
                    .buttonStyle(.plain)
                }
            }

            // Selected type label
            Text(selectedType.label)
                .font(.caption)
                .foregroundColor(Color.pdBrownLight)
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview("Bristol Selector") {
    struct Preview: View {
        @State var selected: BristolType = .smoothSausage
        var body: some View {
            BristolSelector(selectedType: $selected)
                .padding()
                .background(Color.pdCream)
        }
    }
    return Preview()
}
