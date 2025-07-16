import SwiftUI

@main
struct PaceringApp: App {
    var activityLogger = ActivityLogger()

    var body: some Scene {
        WindowGroup {
            if #available(macOS 13.0, *) {
                ContentView(activityLogger: activityLogger)
                    .background(Color.white)
                    .onAppear {
                        activityLogger.startLogging(withInterval: 1.0)
                        activityLogger.startPeriodicChecks()  // Start periodic checks
                    }
            } else {
                // Fallback on earlier versions
            }
        }
    }
}
