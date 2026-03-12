import SwiftUI

// MARK: - Color Palette
extension Color {
    static let pdPeach = Color(red: 1.0, green: 0.85, blue: 0.78)
    static let pdMint = Color(red: 0.75, green: 0.95, blue: 0.85)
    static let pdLavender = Color(red: 0.83, green: 0.78, blue: 0.95)
    static let pdCream = Color(red: 1.0, green: 0.98, blue: 0.94)
    static let pdPink = Color(red: 1.0, green: 0.82, blue: 0.86)
    static let pdBrown = Color(red: 0.55, green: 0.38, blue: 0.28)
    static let pdBrownLight = Color(red: 0.72, green: 0.58, blue: 0.48)
    static let pdCardBackground = Color(red: 1.0, green: 0.97, blue: 0.95)
    
    // Difficulty
    static let pdEasy = Color(red: 0.6, green: 0.88, blue: 0.7)
    static let pdNormal = Color(red: 0.75, green: 0.85, blue: 0.95)
    static let pdStraining = Color(red: 1.0, green: 0.85, blue: 0.6)
    static let pdPainful = Color(red: 1.0, green: 0.7, blue: 0.7)
}

// MARK: - Card Style
struct PDCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.pdCardBackground)
            .cornerRadius(16)
            .shadow(color: Color.pdBrown.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func pdCard() -> some View {
        modifier(PDCardStyle())
    }
}

// MARK: - Primary Button Style
struct PDPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(width: 200, height: 20)
            .padding(.vertical, 16)
            .background(Color.pdPink)
            .cornerRadius(20)
            .shadow(color: Color.pdPink.opacity(0.4), radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Delete Button Style
struct PDDeleteButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.pdPainful)
            .cornerRadius(14)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
