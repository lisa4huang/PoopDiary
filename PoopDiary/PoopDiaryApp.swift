import SwiftUI
import CoreData

/// Main app entry point for Poop Diary.
@main
struct PoopDiaryApp: App {
    let coreDataStack = CoreDataStack.shared

    var body: some Scene {
        WindowGroup {
            ContentView(context: coreDataStack.container.viewContext)
        }
    }
}
