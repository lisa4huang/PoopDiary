import Foundation

/// Difficulty level for a bowel movement.
enum Difficulty: Int16, CaseIterable, Identifiable {
    case easy = 0
    case normal = 1
    case straining = 2
    case painful = 3

    var id: Int16 { rawValue }

    var label: String {
        switch self {
        case .easy: return "Easy"
        case .normal: return "Normal"
        case .straining: return "Straining"
        case .painful: return "Painful"
        }
    }

    var icon: String {
        switch self {
        case .easy: return "😊"
        case .normal: return "😐"
        case .straining: return "😣"
        case .painful: return "😖"
        }
    }

    var color: String {
        switch self {
        case .easy: return "DifficultyEasy"
        case .normal: return "DifficultyNormal"
        case .straining: return "DifficultyStraining"
        case .painful: return "DifficultyPainful"
        }
    }
}
