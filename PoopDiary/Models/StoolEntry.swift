import CoreData

/// Core Data managed object for a stool diary entry.
@objc(StoolEntry)
public class StoolEntry: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var dateTime: Date
    @NSManaged public var bristolType: Int16
    @NSManaged public var difficulty: Int16
    @NSManaged public var durationSeconds: Int32
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date

    /// Safely retrieve ID without bridging crashes.
    var safeID: UUID {
        return (value(forKey: "id") as? UUID) ?? UUID()
    }

    // MARK: - Convenience Accessors

    var bristolTypeEnum: BristolType {
        get { BristolType(rawValue: bristolType) ?? .smoothSausage }
        set { bristolType = newValue.rawValue }
    }

    var difficultyEnum: Difficulty {
        get { Difficulty(rawValue: difficulty) ?? .normal }
        set { difficulty = newValue.rawValue }
    }

    var durationMinutes: Double {
        Double(durationSeconds) / 60.0
    }

    var formattedDuration: String {
        let mins = Int(durationSeconds / 60)
        if mins == 0 { return "<1m" }
        return "\(mins)m"
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: dateTime)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dateTime)
    }
}
