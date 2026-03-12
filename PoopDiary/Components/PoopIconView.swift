import SwiftUI

// Simple global cache to prevent flickering during view refreshes
private var iconCache: [String: UIImage] = [:]

/// Loads a Bristol icon PNG with image caching.
func bristolIconImage(_ name: String) -> Image {
    if let cached = iconCache[name] {
        return Image(uiImage: cached)
    }
    
    if let url = Bundle.main.url(forResource: name, withExtension: "png", subdirectory: "BristolIcon"),
       let uiImage = UIImage(contentsOfFile: url.path) {
        iconCache[name] = uiImage
        return Image(uiImage: uiImage)
    }
    return Image(systemName: "questionmark.circle")
}

/// Stool icon with image caching.
struct PoopIconView: View {
    let bristolType: BristolType
    var size: CGFloat = 28

    var body: some View {
        bristolIconImage(bristolType.imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .accessibilityLabel("\(bristolType.label)")
    }
}

#Preview("Poop Icons") {
    HStack(spacing: 12) {
        ForEach(BristolType.allCases) { type in
            PoopIconView(bristolType: type)
        }
    }
    .padding()
}
