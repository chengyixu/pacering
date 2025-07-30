import Foundation
import SwiftUI
import Combine
import AppKit

struct ActivityRecord: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    let application: String
    var endTime: Date
    var dailyGoal: Double
    var workApps: [String]
    var sessionId: UUID
    var windowTitle: String?

    var duration: String {
        let timeInterval = Int(endTime.timeIntervalSince(startTime))
        let minutes = timeInterval / 60
        let seconds = timeInterval % 60
        return "\(minutes)min \(seconds)sec"
    }

    var durationInSeconds: Int {
        return Int(endTime.timeIntervalSince(startTime))
    }

    init(startTime: Date, application: String, endTime: Date, dailyGoal: Double, workApps: [String], sessionId: UUID, windowTitle: String? = nil) {
        self.id = UUID()
        self.startTime = startTime
        self.application = application
        self.endTime = endTime
        self.dailyGoal = dailyGoal
        self.workApps = workApps
        self.sessionId = sessionId
        self.windowTitle = windowTitle
    }
}

class ActivityLogger: ObservableObject {
    @Published var records = [ActivityRecord]()
    private var cancellables = Set<AnyCancellable>()
    private var saveDebouncer: Timer?
    private var windowTitleCache: [String: (title: String?, timestamp: Date)] = [:]
    private let cacheExpiration: TimeInterval = 30
    
    @Published var workApps: [String] = [] {
        didSet {
            saveWorkApps()
        }
    }
    
    @Published var currentSessionId: UUID {
        didSet {
            // Persist current session ID to avoid loss on restart
            UserDefaults.standard.set(currentSessionId.uuidString, forKey: "currentSessionId")
        }
    }
    
    // AI Analysis Service
    @Published var glmService = GLMService()

    private var updateTimer: Timer?
    var updateInterval: TimeInterval = 30.0 // Default to 30 seconds
    @AppStorage("workTime") var currentGoal: Double = 8.0  // Default to 8 hours
    private var lastCheckedDate: Date = Date()
    @Published var dailyGoals: [String: Double] = [:]
    private var lastResetDate: Date? = UserDefaults.standard.object(forKey: "lastResetDate") as? Date

    init() {
        // Load saved session ID on app start
        if let savedSessionId = UserDefaults.standard.string(forKey: "currentSessionId"), let uuid = UUID(uuidString: savedSessionId) {
            self.currentSessionId = uuid
        } else {
            self.currentSessionId = UUID()  // Fallback if there's no saved session ID
        }
        
        loadRecords()
        loadDailyGoals()
        loadWorkApps() // Load work apps from storage
        checkAndResetDailyLogs()
        startPeriodicChecks()
        
        // Set up debounced saving
        $records
            .debounce(for: .seconds(3), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.saveRecords()
            }
            .store(in: &cancellables)
    }

    func startLogging(withInterval interval: TimeInterval) {
        updateInterval = interval
        updateTimer?.invalidate() // Invalidate the old timer
        updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            self?.updateActiveApplication()
        }
    }

    func updateWorkTimeGoal(_ newGoal: Double) {
        let todayString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        dailyGoals[todayString] = newGoal
        saveDailyGoals() // Save the updated goals
        NotificationCenter.default.post(name: Notification.Name("WorkTimeUpdated"), object: nil)
    }

    private func updateActiveApplication() {
        guard let appName = NSWorkspace.shared.frontmostApplication?.localizedName else {
            return
        }

        // Use cached window title for better performance
        let windowTitle = getCachedWindowTitle(for: appName)
        let now = Date()
        
        if let lastRecord = records.last, 
           lastRecord.application == appName, 
           lastRecord.windowTitle == windowTitle,
           Calendar.current.isDateInToday(lastRecord.startTime) {
            DispatchQueue.main.async {
                if self.records.count > 0 {
                    self.records[self.records.count - 1].endTime = now
                }
            }
        } else {
            let newRecord = ActivityRecord(
                startTime: now,
                application: appName,
                endTime: now,
                dailyGoal: currentGoal,
                workApps: workApps,
                sessionId: currentSessionId,
                windowTitle: windowTitle
            )
            DispatchQueue.main.async {
                self.records.append(newRecord)
            }
        }
    }
    
    private func getCachedWindowTitle(for appName: String) -> String? {
        // Check cache first
        if let cached = windowTitleCache[appName],
           Date().timeIntervalSince(cached.timestamp) < cacheExpiration {
            return cached.title
        }
        
        // For non-browser apps, skip window title fetching to improve performance
        guard appName.lowercased().contains("safari") || 
              appName.lowercased().contains("chrome") else {
            windowTitleCache[appName] = (nil, Date())
            return nil
        }
        
        // Fetch and cache new title
        let title = getWindowTitle(for: appName)
        windowTitleCache[appName] = (title, Date())
        return title
    }
    
    private func getWindowTitle(for appName: String) -> String? {
        // For browsers, try to get tab title via AppleScript
        if appName.lowercased().contains("safari") {
            return getSafariTabTitle()
        } else if appName.lowercased().contains("chrome") {
            return getChromeTabTitle()
        } else {
            // For other apps, try to get window title via Core Graphics
            return getGeneralWindowTitle()
        }
    }
    
    private func getSafariTabTitle() -> String? {
        let script = """
            tell application "Safari"
                if (count of windows) > 0 then
                    return name of current tab of front window
                end if
            end tell
        """
        return executeAppleScript(script)
    }
    
    private func getChromeTabTitle() -> String? {
        let script = """
            tell application "Google Chrome"
                if (count of windows) > 0 then
                    return title of active tab of front window
                end if
            end tell
        """
        return executeAppleScript(script)
    }
    
    private func getGeneralWindowTitle() -> String? {
        let options = CGWindowListOption(arrayLiteral: .optionOnScreenOnly)
        guard let windowList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
            return nil
        }
        
        let frontmostAppName = NSWorkspace.shared.frontmostApplication?.localizedName
        
        for window in windowList {
            if let windowName = window[kCGWindowName as String] as? String,
               let ownerName = window[kCGWindowOwnerName as String] as? String,
               ownerName == frontmostAppName,
               !windowName.isEmpty {
                return windowName
            }
        }
        return nil
    }
    
    private func executeAppleScript(_ script: String) -> String? {
        var error: NSDictionary?
        let scriptObject = NSAppleScript(source: script)
        let result = scriptObject?.executeAndReturnError(&error)
        
        if let error = error {
            print("AppleScript error: \(error)")
            return nil
        }
        
        return result?.stringValue
    }


    private func checkAndResetDailyLogs() {
        let today = Calendar.current.startOfDay(for: Date())
        if lastResetDate == nil || !Calendar.current.isDate(lastResetDate!, inSameDayAs: today) {
            resetTodayRecords()
            lastResetDate = today
            UserDefaults.standard.set(today, forKey: "lastResetDate")
            saveRecords()
        }
    }

    func startPeriodicChecks() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.checkForNewDay()
        }
    }

    private func checkForNewDay() {
        let today = Calendar.current.startOfDay(for: Date())
        if lastCheckedDate < today {
            resetToday()
            lastCheckedDate = today
        }
    }

    func resetToday() {
        resetTodayRecords()
    }

    
    private func resetTodayRecords() {
        DispatchQueue.main.async {
            self.currentSessionId = UUID()
            self.records.removeAll(where: { Calendar.current.isDateInToday($0.startTime) })
        }
    }


    func getRecordsForCurrentSession() -> [ActivityRecord] {
        return records.filter { $0.sessionId == currentSessionId }
    }


    private func saveRecords() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(records) {
            UserDefaults.standard.set(encoded, forKey: "activityRecords")
        }
    }

    private func loadRecords() {
        if let savedRecords = UserDefaults.standard.data(forKey: "activityRecords") {
            let decoder = JSONDecoder()
            if let decodedRecords = try? decoder.decode([ActivityRecord].self, from: savedRecords) {
                records = decodedRecords
            } else {
                // Try to decode old format without windowTitle for backward compatibility
                print("Failed to decode records with new format, attempting migration")
                records = []
            }
        }
    }

    func summarizeActivity() -> [String: Int] {
        var summary: [String: Int] = [:]
        let currentSessionRecords = records.filter { $0.sessionId == currentSessionId }
        for record in currentSessionRecords {
            let duration = Int(record.endTime.timeIntervalSince(record.startTime))
            summary[record.application, default: 0] += duration
        }
        return summary
    }

    private func loadDailyGoals() {
        if let data = UserDefaults.standard.data(forKey: "dailyGoals"), let storedGoals = try? JSONDecoder().decode([String: Double].self, from: data) {
            dailyGoals = storedGoals
        }
    }

    private func saveDailyGoals() {
        if let data = try? JSONEncoder().encode(dailyGoals) {
            UserDefaults.standard.set(data, forKey: "dailyGoals")
        }
    }

    private func loadWorkApps() {
        if let savedWorkApps = UserDefaults.standard.stringArray(forKey: "workApps") {
            workApps = savedWorkApps
        } else {
            // Set default work apps if nothing is saved
            workApps = ["Microsoft Excel", "Microsoft Outlook", "Google Chrome", "Pacering", "Xcode"]
        }
    }


    private func saveWorkApps() {
        UserDefaults.standard.set(workApps, forKey: "workApps")
    }

    func updateWorkApps(_ newWorkApps: [String]) {
        workApps = newWorkApps
    }

    func workAppsToday() -> String {
        let today = Calendar.current.startOfDay(for: Date())
        let totalWorkSeconds = records
            .filter { workApps.contains($0.application) && Calendar.current.isDate($0.startTime, inSameDayAs: today) }
            .reduce(0) { $0 + $1.durationInSeconds }
        let hours = totalWorkSeconds / 3600
        let minutes = (totalWorkSeconds % 3600) / 60
        return "\(hours)h \(minutes)m work today"
    }


    func getDailyProgress() -> [(date: String, progress: Double)] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"

        var dailyProgresses: [(date: String, progress: Double)] = []
        let groupedRecords = Dictionary(grouping: records) { calendar.startOfDay(for: $0.startTime) }

        // Create a list of the last 30 days starting from today
        var dates: [Date] = []
        for i in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            dates.append(calendar.startOfDay(for: date))
        }

        for date in dates {
            let dateString = dateFormatter.string(from: date)
            let isToday = calendar.isDateInToday(date)
            
            if let records = groupedRecords[date] {
                let totalWorkSeconds = records
                    .filter { (isToday ? workApps : $0.workApps).contains($0.application) }
                    .reduce(0) { $0 + $1.durationInSeconds }

                let dayGoalHours = isToday ? currentGoal : records.first?.dailyGoal ?? currentGoal
                let totalWorkHours = Double(totalWorkSeconds) / 3600
                let progress = min(1, totalWorkHours / dayGoalHours)
                dailyProgresses.append((date: dateString, progress: progress))
            } else {
                // If no records for this day, show 0 progress
                dailyProgresses.append((date: dateString, progress: 0.0))
            }
        }

        return dailyProgresses
    }
    
    func generateAIAnalysis() {
        let todayRecords = records.filter { Calendar.current.isDate($0.startTime, inSameDayAs: Date()) }
        glmService.analyzeActivityData(todayRecords)
    }
}

extension ActivityLogger {
    func totalActiveToday() -> String {
        let today = Calendar.current.startOfDay(for: Date())
        let totalSeconds = records
            .filter { Calendar.current.isDate($0.startTime, inSameDayAs: today) }
            .reduce(0) { $0 + $1.durationInSeconds }
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        return "\(hours)h \(minutes)m active today"
    }
}
