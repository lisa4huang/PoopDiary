import CoreData
import SwiftUI

/// Manages stool diary data and statistics.
class StoolViewModel: ObservableObject {
    let viewContext: NSManagedObjectContext

    @Published var todayEntries: [StoolEntry] = []
    @Published var allEntries: [StoolEntry] = []

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchAll()
    }

    // MARK: - Data Fetching

    func fetchAll() {
        fetchTodayEntries()
        fetchAllEntries()
    }

    func fetchTodayEntries() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let request = NSFetchRequest<StoolEntry>(entityName: "StoolEntry")
        request.predicate = NSPredicate(format: "dateTime >= %@ AND dateTime < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "dateTime", ascending: false)]

        do {
            todayEntries = try viewContext.fetch(request)
        } catch {
            todayEntries = []
        }
    }

    func fetchAllEntries() {
        let request = NSFetchRequest<StoolEntry>(entityName: "StoolEntry")
        request.sortDescriptors = [NSSortDescriptor(key: "dateTime", ascending: false)]

        do {
            allEntries = try viewContext.fetch(request)
        } catch {
            allEntries = []
        }
    }

    // MARK: - Create

    func addEntry(
        dateTime: Date,
        bristolType: BristolType,
        difficulty: Difficulty,
        durationSeconds: Int32,
        notes: String
    ) {
        let validatedTime = min(dateTime, Date())
        let validatedDuration = min(durationSeconds, 3600)

        let entry = NSEntityDescription.insertNewObject(forEntityName: "StoolEntry", into: viewContext) as! StoolEntry
        entry.id = UUID()
        entry.dateTime = validatedTime
        entry.bristolType = bristolType.rawValue
        entry.difficulty = difficulty.rawValue
        entry.durationSeconds = validatedDuration
        entry.notes = notes.isEmpty ? nil : notes
        entry.createdAt = Date()
        entry.updatedAt = Date()

        save()
        fetchAll()
    }

    // MARK: - Update

    func updateEntry(
        _ entry: StoolEntry,
        dateTime: Date,
        bristolType: BristolType,
        difficulty: Difficulty,
        durationSeconds: Int32,
        notes: String
    ) {
        entry.dateTime = min(dateTime, Date())
        entry.bristolType = bristolType.rawValue
        entry.difficulty = difficulty.rawValue
        entry.durationSeconds = min(durationSeconds, 3600)
        entry.notes = notes.isEmpty ? nil : notes
        entry.updatedAt = Date()

        save()
        fetchAll()
    }

    // MARK: - Delete

    func deleteEntry(byId id: UUID) {
        let request = NSFetchRequest<StoolEntry>(entityName: "StoolEntry")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try viewContext.fetch(request)
            for entry in results {
                viewContext.delete(entry)
            }
            save()
            fetchAll()
        } catch {
            // Error handling
        }
    }

    // MARK: - Save

    private func save() {
        do {
            try viewContext.save()
        } catch {
            // Error handling
        }
    }

    // MARK: - Stats

    /// Group entries by day for list display.
    var entriesGroupedByDay: [(date: Date, entries: [StoolEntry])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: allEntries) { entry in
            calendar.startOfDay(for: entry.dateTime)
        }
        return grouped
            .map { (date: $0.key, entries: $0.value.sorted { $0.dateTime < $1.dateTime }) }
            .sorted { $0.date > $1.date }
    }

    /// Average session duration in minutes.
    var averageDuration: Double {
        let entriesWithDuration = allEntries.filter { $0.durationSeconds > 0 }
        guard !entriesWithDuration.isEmpty else { return 0 }
        let total = entriesWithDuration.reduce(0) { $0 + Double($1.durationSeconds) }
        return (total / Double(entriesWithDuration.count)) / 60.0
    }

    /// Total entries count.
    var totalEntries: Int {
        allEntries.count
    }

    /// Most common Bristol type.
    var mostCommonType: BristolType? {
        let counts = Dictionary(grouping: allEntries) { $0.bristolType }
        guard let mostCommon = counts.max(by: { $0.value.count < $1.value.count }) else { return nil }
        return BristolType(rawValue: mostCommon.key)
    }

    /// Dictionary of stool count and most frequent type per day.
    func monthlyHabitData(for monthDate: Date) -> [Int: (count: Int, type: BristolType?)] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: monthDate)!
        let components = calendar.dateComponents([.year, .month], from: monthDate)
        
        var data: [Int: (count: Int, type: BristolType?)] = [:]
        
        for day in 1...range.count {
            var dayComponents = components
            dayComponents.day = day
            let date = calendar.date(from: dayComponents)!
            let nextDay = calendar.date(byAdding: .day, value: 1, to: date)!
            
            let dayEntries = allEntries.filter { $0.dateTime >= date && $0.dateTime < nextDay }
            if !dayEntries.isEmpty {
                let counts = Dictionary(grouping: dayEntries) { $0.bristolTypeEnum }
                let mostFrequentType = counts.max(by: { $0.value.count < $1.value.count })?.key
                data[day] = (count: dayEntries.count, type: mostFrequentType)
            }
        }
        return data
    }

    /// Current streak in days.
    var streakCount: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var currentStreak = 0
        var checkDate = today
        
        let daysWithEntries = Set(allEntries.map { calendar.startOfDay(for: $0.dateTime) })

        if !daysWithEntries.contains(today) {
            checkDate = calendar.date(byAdding: .day, value: -1, to: today)!
        }
        
        while daysWithEntries.contains(checkDate) {
            currentStreak += 1
            guard let nextDate = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = nextDate
        }
        
        return currentStreak
    }

    /// Formatted time of the last entry.
    var lastEntryTime: String {
        guard let lastEntry = allEntries.sorted(by: { $0.dateTime < $1.dateTime }).last else {
            return "--:--"
        }
        return lastEntry.formattedTime
    }
    /// Percentage distribution of Bristol types over the last 7 days.
    var typeConsistencyData: [(type: BristolType, percentage: Double)] {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        let recentEntries = allEntries.filter { $0.dateTime >= sevenDaysAgo }
        
        guard !recentEntries.isEmpty else { return [] }
        
        let counts = Dictionary(grouping: recentEntries) { $0.bristolTypeEnum }
        let total = Double(recentEntries.count)
        
        return BristolType.allCases.compactMap { type in
            guard let count = counts[type]?.count, count > 0 else { return nil }
            return (type: type, percentage: Double(count) / total)
        }
    }

    /// Sunday-to-Saturday overview for the current week, including the most frequent type per day.
    var weeklyOverview: [(dayName: String, date: Date, type: BristolType?)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: today)!
        
        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        
        return (0..<7).map { dayOffset in
            let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)!
            let nextDay = calendar.date(byAdding: .day, value: 1, to: dayDate)!
            let dayEntries = allEntries.filter { $0.dateTime >= dayDate && $0.dateTime < nextDay }
            
            let mostFrequentType: BristolType?
            if !dayEntries.isEmpty {
                let counts = Dictionary(grouping: dayEntries) { $0.bristolTypeEnum }
                mostFrequentType = counts.max(by: { $0.value.count < $1.value.count })?.key
            } else {
                mostFrequentType = nil
            }
            
            return (dayName: dayNames[dayOffset], date: dayDate, type: mostFrequentType)
        }
    }
}
