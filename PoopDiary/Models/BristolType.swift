import Foundation
import SwiftUI

/// Bristol Stool Chart classification with cute emoji icons.
enum BristolType: Int16, CaseIterable, Identifiable {
    case hardLumps = 1
    case lumpySausage = 2
    case crackedSausage = 3
    case smoothSausage = 4
    case softBlobs = 5
    case mushy = 6
    case watery = 7

    var id: Int16 { rawValue }

    var imageName: String {
        switch self {
        case .hardLumps: return "Hard Lumps"
        case .lumpySausage: return "Lumpy Sausage"
        case .crackedSausage: return "Cracked Sausage"
        case .smoothSausage: return "Smooth Sausage"
        case .softBlobs: return "Soft Blobs"
        case .mushy: return "Mushy"
        case .watery: return "Watery"
        }
    }

    var label: String {
        switch self {
        case .hardLumps: return "Hard Lumps"
        case .lumpySausage: return "Lumpy"
        case .crackedSausage: return "Cracked"
        case .smoothSausage: return "Smooth"
        case .softBlobs: return "Soft"
        case .mushy: return "Mushy"
        case .watery: return "Watery"
        }
    }

    var typeNumber: String {
        "Type \(rawValue)"
    }
}
