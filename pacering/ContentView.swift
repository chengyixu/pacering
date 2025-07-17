import SwiftUI
import AppKit
import ServiceManagement

// MARK: - Language Support
enum AppLanguage: String, CaseIterable {
    case english = "en"
    case chinese = "zh"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .chinese: return "中文"
        }
    }
}

class LanguageManager: ObservableObject {
    @Published var currentLanguage: AppLanguage = .english
    
    init() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "app_language"),
           let language = AppLanguage(rawValue: savedLanguage) {
            currentLanguage = language
        }
    }
    
    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "app_language")
    }
}

extension String {
    func localized(_ language: AppLanguage = .english) -> String {
        let translations: [String: [AppLanguage: String]] = [
            "Pacering": [.english: "Pacering", .chinese: "Pacering"],
            "Productivity Tracker": [.english: "Productivity Tracker", .chinese: "生产力追踪器"],
            "Today": [.english: "Today", .chinese: "今天"],
            "Profile": [.english: "Profile", .chinese: "配置"],
            "Work Apps": [.english: "Work Apps", .chinese: "工作应用"],
            "Language": [.english: "Language", .chinese: "语言"],
            "No activity": [.english: "No activity", .chinese: "无活动"],
            "Complete": [.english: "Complete", .chinese: "已完成"],
            "Today's Activity": [.english: "Today's Activity", .chinese: "今日活动"],
            "30-Day Progress": [.english: "30-Day Progress", .chinese: "30天进度"],
            "Settings": [.english: "Settings", .chinese: "设置"],
            "Customize your productivity tracking": [.english: "Customize your productivity tracking", .chinese: "自定义您的生产力追踪"],
            "Daily Work Goal": [.english: "Daily Work Goal", .chinese: "每日工作目标"],
            "Set your daily work time target": [.english: "Set your daily work time target", .chinese: "设置您的每日工作时间目标"],
            "Update Interval": [.english: "Update Interval", .chinese: "更新间隔"],
            "How often to check active applications": [.english: "How often to check active applications", .chinese: "检查活动应用程序的频率"],
            "Startup": [.english: "Startup", .chinese: "启动"],
            "Automatically start Pacering when you log in": [.english: "Automatically start Pacering when you log in", .chinese: "登录时自动启动Pacering"],
            "Launch at Login": [.english: "Launch at Login", .chinese: "登录时启动"],
            "Reset Data": [.english: "Reset Data", .chinese: "重置数据"],
            "Clear today's activity data": [.english: "Clear today's activity data", .chinese: "清除今日活动数据"],
            "Reset Today's Progress": [.english: "Reset Today's Progress", .chinese: "重置今日进度"],
            "hours": [.english: "hours", .chinese: "小时"],
            "sec": [.english: "sec", .chinese: "秒"],
            "mins": [.english: "mins", .chinese: "分钟"],
            "secs": [.english: "secs", .chinese: "秒"],
            "Work Applications": [.english: "Work Applications", .chinese: "工作应用程序"],
            "Select which applications should count as work time": [.english: "Select which applications should count as work time", .chinese: "选择哪些应用程序应计为工作时间"],
            "Search applications...": [.english: "Search applications...", .chinese: "搜索应用程序..."],
            "Work App": [.english: "Work App", .chinese: "工作应用"],
            "Personal App": [.english: "Personal App", .chinese: "个人应用"],
            "WORK": [.english: "WORK", .chinese: "工作"],
            "apps selected as work applications": [.english: "apps selected as work applications", .chinese: "个应用程序被选为工作应用程序"],
            "Save Work Apps": [.english: "Save Work Apps", .chinese: "保存工作应用程序"],
            "AI Analysis": [.english: "AI Analysis", .chinese: "AI分析"],
            "AI Insights": [.english: "AI Insights", .chinese: "AI洞察"],
            "Intelligent insights about your productivity": [.english: "Intelligent insights about your productivity", .chinese: "关于您工作效率的智能洞察"],
            "Generate Analysis": [.english: "Generate Analysis", .chinese: "生成分析"],
            "Analyzing...": [.english: "Analyzing...", .chinese: "分析中..."],
            "Ready for AI Analysis": [.english: "Ready for AI Analysis", .chinese: "准备进行AI分析"],
            "Today's Activity Preview": [.english: "Today's Activity Preview", .chinese: "今日活动预览"],
            "Apps Used": [.english: "Apps Used", .chinese: "使用的应用"],
            "Total Time": [.english: "Total Time", .chinese: "总时间"],
            "Error": [.english: "Error", .chinese: "错误"],
            "Click the 'Generate Analysis' button to get intelligent insights about your productivity patterns": [.english: "Click the 'Generate Analysis' button to get intelligent insights about your productivity patterns", .chinese: "点击'生成分析'按钮，获取有关您工作效率模式的智能洞察"],
            "Copy": [.english: "Copy", .chinese: "复制"],
            "Copied!": [.english: "Copied!", .chinese: "已复制！"],
            "Analysis Results": [.english: "Analysis Results", .chinese: "分析结果"]
        ]
        
        return translations[self]?[language] ?? self
    }
}

struct ContentView: View {
    @ObservedObject var activityLogger: ActivityLogger
    @StateObject private var languageManager = LanguageManager()
    @State private var selectedView: String = "Pacering"  // Default view is "Pacering"

    init(activityLogger: ActivityLogger) {
        self.activityLogger = activityLogger
    }
    
    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                // Header Section
                VStack(spacing: 16) {
                    HStack {
                        Image("logowithoutname")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Pacering".localized(languageManager.currentLanguage))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(hex: "012379"))
                            
                            Text("Productivity Tracker".localized(languageManager.currentLanguage))
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // Stats Summary
                    VStack(spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(activityLogger.workAppsToday())
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(Color(hex: "012379"))
                                
                                Text(activityLogger.totalActiveToday())
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "012379").opacity(0.05))
                        )
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 16)
                
                // Navigation List
                List(selection: $selectedView) {
                    NavigationLink(value: "Today") {
                        HStack(spacing: 12) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(selectedView == "Today" ? .white : Color(hex: "012379"))
                                .frame(width: 20)
                            
                            Text("Today".localized(languageManager.currentLanguage))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedView == "Today" ? .white : .primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedView == "Today" ? Color(hex: "012379") : Color.clear)
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    
                    NavigationLink(value: "Pacering") {
                        HStack(spacing: 12) {
                            Image(systemName: "chart.pie.fill")
                                .foregroundColor(selectedView == "Pacering" ? .white : Color(hex: "012379"))
                                .frame(width: 20)
                            
                            Text("Pacering".localized(languageManager.currentLanguage))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedView == "Pacering" ? .white : .primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedView == "Pacering" ? Color(hex: "012379") : Color.clear)
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    
                    NavigationLink(value: "Profile") {
                        HStack(spacing: 12) {
                            Image(systemName: "person.fill")
                                .foregroundColor(selectedView == "Profile" ? .white : Color(hex: "012379"))
                                .frame(width: 20)
                            
                            Text("Profile".localized(languageManager.currentLanguage))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedView == "Profile" ? .white : .primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedView == "Profile" ? Color(hex: "012379") : Color.clear)
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    
                    NavigationLink(value: "Work Apps") {
                        HStack(spacing: 12) {
                            Image(systemName: "briefcase.fill")
                                .foregroundColor(selectedView == "Work Apps" ? .white : Color(hex: "012379"))
                                .frame(width: 20)
                            
                            Text("Work Apps".localized(languageManager.currentLanguage))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedView == "Work Apps" ? .white : .primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedView == "Work Apps" ? Color(hex: "012379") : Color.clear)
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    
                    NavigationLink(value: "AI Analysis") {
                        HStack(spacing: 12) {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(selectedView == "AI Analysis" ? .white : Color(hex: "012379"))
                                .frame(width: 20)
                            
                            Text("AI Analysis".localized(languageManager.currentLanguage))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedView == "AI Analysis" ? .white : .primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedView == "AI Analysis" ? Color(hex: "012379") : Color.clear)
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 16)
                
                Spacer()
                
                // Language Button at the bottom
                VStack(spacing: 8) {
                    Divider()
                        .padding(.horizontal, 16)
                    
                    Button(action: {
                        languageManager.setLanguage(
                            languageManager.currentLanguage == .english ? .chinese : .english
                        )
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "globe")
                                .foregroundColor(Color(hex: "012379"))
                                .frame(width: 20)
                            
                            Text("Language".localized(languageManager.currentLanguage))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text(languageManager.currentLanguage.displayName)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.clear)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 16)
            }
            .frame(minWidth: 200, idealWidth: 250, maxWidth: 300, maxHeight: .infinity)
            .background(Color.white)
        } detail: {
            // Default content view based on selection
            switch selectedView {
            case "Today":
                TodayView(activityLogger: activityLogger, selectedView: $selectedView, languageManager: languageManager)
            case "Pacering":
                PaceringView(activityLogger: activityLogger, languageManager: languageManager)
            case "Profile":
                ProfileView(activityLogger: activityLogger, languageManager: languageManager)
            case "Work Apps":
                WorkAppsView(activityLogger: activityLogger, languageManager: languageManager)
            case "AI Analysis":
                AIAnalysisView(activityLogger: activityLogger, languageManager: languageManager)
            default:
                Text("Select a view from the sidebar")
            }
        }
        .frame(minWidth: 800, idealWidth: 1000, maxWidth: .infinity, maxHeight: .infinity)
    }
}



struct TodayView: View {
    @ObservedObject var activityLogger: ActivityLogger
    @Binding var selectedView: String
    @ObservedObject var languageManager: LanguageManager
    
    private func formatHour(_ hour: Int) -> String {
        let period = hour < 12 ? "AM" : "PM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return String(format: "%d:00 %@", displayHour, period)
    }
    
    private func getRecordsForHour(_ hour: Int) -> [ActivityRecord] {
        return activityLogger.getRecordsForCurrentSession().filter { 
            Calendar.current.component(.hour, from: $0.startTime) == hour 
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                List {
                    ForEach(0..<24, id: \.self) { hour in
                        let records = getRecordsForHour(hour)
                        let isCurrentHour = Calendar.current.component(.hour, from: Date()) == hour
                        
                        VStack(alignment: .leading, spacing: 0) {
                            // Hour header with better styling
                            HStack {
                                Text(formatHour(hour))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(isCurrentHour ? Color(hex: "012379") : .secondary)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                
                                Spacer()
                                
                                if isCurrentHour {
                                    Circle()
                                        .fill(Color(hex: "012379"))
                                        .frame(width: 8, height: 8)
                                        .padding(.trailing, 16)
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isCurrentHour ? Color(hex: "012379").opacity(0.05) : Color.clear)
                            )
                            .id(hour)
                            
                            // App records with improved design
                            if !records.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    ForEach(records) { record in
                                        HStack {
                                            // App icon placeholder
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(activityLogger.workApps.contains(record.application) ? 
                                                      Color(hex: "012379").opacity(0.1) : Color.gray.opacity(0.1))
                                                .frame(width: 6, height: 20)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(record.application)
                                                    .font(.system(size: 13, weight: .medium))
                                                    .foregroundColor(activityLogger.workApps.contains(record.application) ? 
                                                                   Color(hex: "012379") : .primary)
                                                
                                                if let windowTitle = record.windowTitle, !windowTitle.isEmpty {
                                                    Text(windowTitle)
                                                        .font(.system(size: 11))
                                                        .foregroundColor(.secondary)
                                                        .lineLimit(1)
                                                        .truncationMode(.tail)
                                                }
                                                
                                                Text(record.duration)
                                                    .font(.system(size: 11))
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            // Work app indicator
                                            if activityLogger.workApps.contains(record.application) {
                                                Image(systemName: "briefcase.fill")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(Color(hex: "012379"))
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color.white)
                                                .shadow(color: Color.black.opacity(0.02), radius: 1, x: 0, y: 1)
                                        )
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.bottom, 8)
                            } else {
                                // Empty state for hours with no activity
                                HStack {
                                    Text("No activity".localized(languageManager.currentLanguage))
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                        .italic()
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 4)
                                    Spacer()
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color(NSColor.controlBackgroundColor))
                .onAppear {
                    // Auto-scroll to current hour
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        let currentHour = Calendar.current.component(.hour, from: Date())
                        withAnimation(.easeInOut(duration: 1.0)) {
                            proxy.scrollTo(currentHour, anchor: .top)
                        }
                    }
                }
                .onChange(of: selectedView) { newValue in
                    if newValue == "Today" {
                        // Auto-scroll when switching to Today tab
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            let currentHour = Calendar.current.component(.hour, from: Date())
                            withAnimation(.easeInOut(duration: 1.0)) {
                                proxy.scrollTo(currentHour, anchor: .top)
                            }
                        }
                    }
                }
            }
        }
        .background(Color.white)
    }
}

struct PaceringView: View {
    @ObservedObject var activityLogger: ActivityLogger
    @ObservedObject var languageManager: LanguageManager
    @State private var progressFraction: Double = 0.0
    
    private func updateProgress() {
        let workApps = activityLogger.workApps
        let totalWorkSeconds = activityLogger.getRecordsForCurrentSession()
            .filter { workApps.contains($0.application) }
            .reduce(0) { $0 + $1.durationInSeconds }
        let totalWorkHours = Double(totalWorkSeconds) / 3600

        let todayString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let todayGoal = activityLogger.dailyGoals[todayString] ?? activityLogger.currentGoal
        self.progressFraction = min(1, totalWorkHours / todayGoal)
    }

    var body: some View {
        VStack(spacing: 20) {
            // Main progress circle section
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 25)
                        .opacity(0.15)
                        .foregroundColor(Color(hex: "012379"))
                    
                    PartialCircle(progress: progressFraction)
                        .stroke(style: StrokeStyle(lineWidth: 25, lineCap: .round))
                        .foregroundColor(Color(hex: "012379"))
                        .rotationEffect(.degrees(-90))
                    
                    // Progress text in center
                    VStack(spacing: 4) {
                        Text("\(Int(progressFraction * 100))%")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(hex: "012379"))
                        
                        Text("Complete".localized(languageManager.currentLanguage))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 220, height: 220)
                .onAppear {
                    updateProgress()
                }
                .onReceive(activityLogger.$records) { _ in
                    updateProgress()
                }
            }
            .padding(.top, 20)
            
            HStack(spacing: 40) {
                // Activity summary section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Today's Activity".localized(languageManager.currentLanguage))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "012379"))
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(activityLogger.summarizeActivity()
                                        .sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                                HStack {
                                    // App indicator
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(activityLogger.workApps.contains(key) ? 
                                              Color(hex: "012379") : Color.gray.opacity(0.3))
                                        .frame(width: 6, height: 16)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(key)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(activityLogger.workApps.contains(key) ? 
                                                           Color(hex: "012379") : .primary)
                                        
                                        Text(formatDuration(value, language: languageManager.currentLanguage))
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if activityLogger.workApps.contains(key) {
                                        Image(systemName: "briefcase.fill")
                                            .font(.system(size: 10))
                                            .foregroundColor(Color(hex: "012379"))
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                                )
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
                .frame(minWidth: 200, maxWidth: 250)
                
                // Daily progress history
                VStack(alignment: .leading, spacing: 16) {
                    Text("30-Day Progress".localized(languageManager.currentLanguage))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "012379"))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(activityLogger.getDailyProgress(), id: \.date) { dailyProgress in
                                VStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .stroke(lineWidth: 6)
                                            .opacity(0.2)
                                            .foregroundColor(Color.gray)
                                        
                                        PartialCircle(progress: dailyProgress.progress)
                                            .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                            .foregroundColor(dailyProgress.progress >= 1 ? 
                                                           Color.green : Color(hex: "012379"))
                                            .rotationEffect(.degrees(-90))
                                    }
                                    .frame(width: 40, height: 40)
                                    
                                    Text(dailyProgress.date)
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                    }
                }
                .frame(minWidth: 200)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(Color.white)
        .padding()
    }
}


func formatDuration(_ totalSeconds: Int, language: AppLanguage = .english) -> String {
    let minutes = totalSeconds / 60
    let seconds = totalSeconds % 60
    return "\(minutes) \("mins".localized(language)) \(seconds) \("secs".localized(language))"
}


struct CommunityView: View {
    var body: some View {
        
        Text("Community features to be implemented")
            .navigationTitle("Community")
        

    }
}

struct ProfileView: View {
    @AppStorage("workTime") var workTime: Double = 8.0 // Default to 8 hours
    @ObservedObject var activityLogger: ActivityLogger
    @ObservedObject var languageManager: LanguageManager
    @State private var selectedIntervalIndex = 0
    @State private var launchAtLogin: Bool

    let intervalOptions = [1, 5, 10, 15, 30, 300] // Predefined intervals in seconds

    init(activityLogger: ActivityLogger, languageManager: LanguageManager) {
        self.activityLogger = activityLogger
        self.languageManager = languageManager
        self._launchAtLogin = State(initialValue: SMAppService.mainApp.status == .enabled)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Settings".localized(languageManager.currentLanguage))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "012379"))
                        
                        Text("Customize your productivity tracking".localized(languageManager.currentLanguage))
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Work Time Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(Color(hex: "012379"))
                                .frame(width: 20)
                            
                            Text("Daily Work Goal".localized(languageManager.currentLanguage))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "012379"))
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Set your daily work time target".localized(languageManager.currentLanguage))
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            
                            Picker("", selection: $workTime) {
                                ForEach([0.5, 1, 2, 4, 8, 12], id: \.self) { time in
                                    Text("\(time, specifier: "%.1f") \("hours".localized(languageManager.currentLanguage))").tag(time)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                    )

                    // Update Interval Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(Color(hex: "012379"))
                                .frame(width: 20)
                            
                            Text("Update Interval".localized(languageManager.currentLanguage))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "012379"))
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("How often to check active applications".localized(languageManager.currentLanguage))
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            
                            Picker("", selection: $selectedIntervalIndex) {
                                ForEach(intervalOptions.indices, id: \.self) { index in
                                    Text("\(intervalOptions[index]) \("sec".localized(languageManager.currentLanguage))").tag(index)
                                }
                            }
                            .pickerStyle(.segmented)
                            .onChange(of: selectedIntervalIndex) { newIndex in
                                let newInterval = TimeInterval(intervalOptions[newIndex])
                                activityLogger.startLogging(withInterval: newInterval)
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                    )

                    // Launch at Login Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "power")
                                .foregroundColor(Color(hex: "012379"))
                                .frame(width: 20)
                            
                            Text("Startup".localized(languageManager.currentLanguage))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "012379"))
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Automatically start Pacering when you log in".localized(languageManager.currentLanguage))
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            
                            Toggle("Launch at Login".localized(languageManager.currentLanguage), isOn: $launchAtLogin)
                                .toggleStyle(SwitchToggleStyle())
                                .onChange(of: launchAtLogin) { [oldValue = launchAtLogin] newValue in
                                    do {
                                        if newValue {
                                            try SMAppService.mainApp.register()
                                        } else {
                                            try SMAppService.mainApp.unregister()
                                        }
                                    } catch {
                                        Swift.print(error.localizedDescription)
                                    }
                                    // Ensure toggle reflects the actual status
                                    if newValue != (SMAppService.mainApp.status == .enabled) {
                                        launchAtLogin = oldValue
                                    }
                                }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                    )

                    // Reset Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.red)
                                .frame(width: 20)
                            
                            Text("Reset Data".localized(languageManager.currentLanguage))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Clear today's activity data".localized(languageManager.currentLanguage))
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                activityLogger.resetToday()
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                        .font(.system(size: 12))
                                    Text("Reset Today's Progress".localized(languageManager.currentLanguage))
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.red)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .onAppear {
            // Sync the index with the current interval from activityLogger
            let currentInterval = activityLogger.updateInterval
            if let index = intervalOptions.firstIndex(of: Int(currentInterval)) {
                selectedIntervalIndex = index
            }
        }
    }
}



struct PartialCircle: Shape {
    var progress: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: rect.width / 2,
                    startAngle: .degrees(0),
                    endAngle: .degrees(progress * 360),
                    clockwise: false)
        return path
    }

    var animatableData: Double {
        get { return progress }
        set { progress = newValue }
    }
}


// test
