import CoreData

/// Persistent Core Data stack with programmatic model definition.
struct CoreDataStack {
    static let shared = CoreDataStack()

    let container: NSPersistentContainer

    /// In-memory instance for SwiftUI previews.
    static var preview: CoreDataStack = {
        let stack = CoreDataStack(inMemory: true)
        let viewContext = stack.container.viewContext

        // Sample data
        let calendar = Calendar.current
        let now = Date()

        for i in 0..<5 {
            let entry = NSEntityDescription.insertNewObject(forEntityName: "StoolEntry", into: viewContext)
            entry.setValue(UUID(), forKey: "id")
            entry.setValue(calendar.date(byAdding: .hour, value: -i * 3, to: now), forKey: "dateTime")
            entry.setValue(Int16([1, 2, 3, 4, 5, 6, 7].randomElement()!), forKey: "bristolType")
            entry.setValue(Int16([0, 1, 2, 3].randomElement()!), forKey: "difficulty")
            entry.setValue(Int32([120, 180, 240, 300, 420].randomElement()!), forKey: "durationSeconds")
            entry.setValue("", forKey: "notes")
            entry.setValue(now, forKey: "createdAt")
            entry.setValue(now, forKey: "updatedAt")
        }

        do {
            try viewContext.save()
        } catch {
            fatalError("Preview CoreData save error: \(error)")
        }

        return stack
    }()

    init(inMemory: Bool = false) {
        let model = CoreDataStack.createModel()
        container = NSPersistentContainer(name: "PoopDiary", managedObjectModel: model)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data store failed to load: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    /// Programmatic model creation.
    private static func createModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // StoolEntry entity
        let stoolEntry = NSEntityDescription()
        stoolEntry.name = "StoolEntry"
        stoolEntry.managedObjectClassName = "StoolEntry"

        // Attributes
        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .UUIDAttributeType
        idAttr.isOptional = false

        let dateTimeAttr = NSAttributeDescription()
        dateTimeAttr.name = "dateTime"
        dateTimeAttr.attributeType = .dateAttributeType
        dateTimeAttr.isOptional = false

        let bristolTypeAttr = NSAttributeDescription()
        bristolTypeAttr.name = "bristolType"
        bristolTypeAttr.attributeType = .integer16AttributeType
        bristolTypeAttr.isOptional = true
        bristolTypeAttr.defaultValue = Int16(4)

        let difficultyAttr = NSAttributeDescription()
        difficultyAttr.name = "difficulty"
        difficultyAttr.attributeType = .integer16AttributeType
        difficultyAttr.isOptional = true
        difficultyAttr.defaultValue = Int16(1)

        let durationSecondsAttr = NSAttributeDescription()
        durationSecondsAttr.name = "durationSeconds"
        durationSecondsAttr.attributeType = .integer32AttributeType
        durationSecondsAttr.isOptional = true
        durationSecondsAttr.defaultValue = Int32(0)

        let notesAttr = NSAttributeDescription()
        notesAttr.name = "notes"
        notesAttr.attributeType = .stringAttributeType
        notesAttr.isOptional = true
        notesAttr.defaultValue = ""

        let createdAtAttr = NSAttributeDescription()
        createdAtAttr.name = "createdAt"
        createdAtAttr.attributeType = .dateAttributeType
        createdAtAttr.isOptional = false

        let updatedAtAttr = NSAttributeDescription()
        updatedAtAttr.name = "updatedAt"
        updatedAtAttr.attributeType = .dateAttributeType
        updatedAtAttr.isOptional = false

        stoolEntry.properties = [
            idAttr, dateTimeAttr, bristolTypeAttr, difficultyAttr,
            durationSecondsAttr, notesAttr, createdAtAttr, updatedAtAttr
        ]

        model.entities = [stoolEntry]
        return model
    }
}
