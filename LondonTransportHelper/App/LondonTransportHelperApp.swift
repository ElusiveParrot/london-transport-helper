import SwiftUI

@main
struct LondonTransportHelperApp: App {
    // Used for .onChange on the body to avoid data loss 'bug' when using CoreData
    @Environment(\.scenePhase) var scenePhase
    
    // Overwrite automatic color scheme setting of iOs and set manually (or automatic when set to automatic)
    @AppStorage(AppSetting.theme.rawValue) private var theme = AppSettingTheme.automatic
    
    // Persistence Storage Controller
    let persistenceController = PersistenceController.shared
    
    // Converts from my settings enum to object that's actually used by '.preferredColorScheme'
    var colorScheme: Optional<ColorScheme> {
        switch (theme) {
        case .automatic:
            return Optional.none
            
        case .light:
            return Optional.some(ColorScheme.light)
            
        case .dark:
            return Optional.some(ColorScheme.dark)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(colorScheme)
        }
        .onChange(of: scenePhase) { _ in
            // Saves changes when going into background
            persistenceController.save()
        }
    }
}
