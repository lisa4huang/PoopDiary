import SwiftUI

// Simple global cache to prevent flickering during view refreshes
private var mascotCache: [String: UIImage] = [:]

/// Loads a Pipi mascot PNG with caching to prevent flickering.
func pipiImage(_ name: String) -> Image {
    if let cached = mascotCache[name] {
        return Image(uiImage: cached)
    }
    
    var uiImage: UIImage?
    
    if let url = Bundle.main.url(forResource: name, withExtension: "png", subdirectory: "Mascot") {
        uiImage = UIImage(contentsOfFile: url.path)
    } else if let url = Bundle.main.url(forResource: name, withExtension: "png") {
        uiImage = UIImage(contentsOfFile: url.path)
    }
    
    if let img = uiImage {
        mascotCache[name] = img
        return Image(uiImage: img)
    }
    
    return Image(systemName: "face.smiling")
}

/// Loads a generic PNG from the app bundle's Resources/Image folder.
func pooImage(_ name: String) -> Image {
    if let cached = mascotCache[name] {
        return Image(uiImage: cached)
    }

    if let url = Bundle.main.url(forResource: name, withExtension: "png", subdirectory: "Image"),
       let uiImage = UIImage(contentsOfFile: url.path) {
        mascotCache[name] = uiImage
        return Image(uiImage: uiImage)
    }
    return Image(systemName: "circle.fill")
}

/// The friendly "Pipi" mascot character.
struct MascotView: View {
    let message: String
    var imageName: String = "Pipi Default"
    var isAnimated: Bool = true
    @State private var bounceOffset: CGFloat = 0
    var size: CGFloat = 100

    var body: some View {
        VStack(spacing: 12) {
            // Pipi Mascot Image
            pipiImage(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: size)
                .offset(y: bounceOffset)

            // Speech bubble
            if !message.isEmpty {
                Text(message)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(Color.pdBrown)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.pdBrown.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
            }
        }
        .onAppear {
            if isAnimated {
                startBouncing()
            }
        }
    }

    private func startBouncing() {
        withAnimation(
            .easeInOut(duration: 1.2)
            .repeatForever(autoreverses: true)
        ) {
            bounceOffset = -6
        }
    }
}

#Preview("Mascot") {
    VStack(spacing: 24) {
        MascotView(message: "Ready to log today's poop? 💪")
    }
    .padding()
    .background(Color.pdCream)
}
