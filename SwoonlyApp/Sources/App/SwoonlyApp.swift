import SwiftUI
import SwiftData

@main
struct SwoonlyApp: App {
    @StateObject private var entitlement = EntitlementStore.shared
    @StateObject private var content = ContentStore.shared
    let container: ModelContainer

    init() {
        let args = ProcessInfo.processInfo.arguments
        MainActor.assumeIsolated {
            if args.contains("--reset") { EntitlementStore.shared.setPro(false) }
            if args.contains("--uitestPro") || args.contains("--screenshots") { EntitlementStore.shared.setPro(true) }
        }
        let isUnitTest = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        let inMemory = args.contains("--reset") || args.contains("--screenshots")
            || args.contains("--lockedPreview") || isUnitTest
        let config = ModelConfiguration(isStoredInMemoryOnly: inMemory, groupContainer: .none)
        if let c = try? ModelContainer(for: AppSettings.self, ReadingProgress.self, SavedStory.self, configurations: config) {
            container = c
        } else {
            try? FileManager.default.removeItem(at: config.url)
            container = try! ModelContainer(for: AppSettings.self, ReadingProgress.self, SavedStory.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: inMemory, groupContainer: .none))
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(entitlement)
                .environmentObject(content)
                .tint(Theme.accent)
        }
        .modelContainer(container)
    }
}
