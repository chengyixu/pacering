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
            "Analysis Results": [.english: "Analysis Results", .chinese: "分析结果"],
            // Tabs
            "Analysis": [.english: "Analysis", .chinese: "分析"],
            "Achievements": [.english: "Achievements", .chinese: "成就"],
            // Achievements View
            "Track your productivity milestones": [.english: "Track your productivity milestones", .chinese: "追踪您的生产力里程碑"],
            "Unlocked": [.english: "Unlocked", .chinese: "已解锁"],
            "Total": [.english: "Total", .chinese: "总计"],
            "All": [.english: "All", .chinese: "全部"],
            "Productivity": [.english: "Productivity", .chinese: "生产力"],
            "Consistency": [.english: "Consistency", .chinese: "一致性"],
            "Exploration": [.english: "Exploration", .chinese: "探索"],
            "Milestones": [.english: "Milestones", .chinese: "里程碑"],
            "Special": [.english: "Special", .chinese: "特殊"],
            // Achievement Titles
            "First Hour": [.english: "First Hour", .chinese: "第一小时"],
            "Workday Warrior": [.english: "Workday Warrior", .chinese: "工作日战士"],
            "Productivity Master": [.english: "Productivity Master", .chinese: "生产力大师"],
            "Week Streak": [.english: "Week Streak", .chinese: "周连续"],
            "Monthly Commitment": [.english: "Monthly Commitment", .chinese: "月度承诺"],
            "App Explorer": [.english: "App Explorer", .chinese: "应用探索者"],
            "Multitasker": [.english: "Multitasker", .chinese: "多任务处理者"],
            "Early Bird": [.english: "Early Bird", .chinese: "早起鸟"],
            "Night Owl": [.english: "Night Owl", .chinese: "夜猫子"],
            "Perfect Balance": [.english: "Perfect Balance", .chinese: "完美平衡"],
            "Goal Crusher": [.english: "Goal Crusher", .chinese: "目标粉碎者"],
            // Achievement Descriptions
            "Complete your first hour of tracked activity": [.english: "Complete your first hour of tracked activity", .chinese: "完成您的第一个小时的跟踪活动"],
            "Complete 8 hours of work in a single day": [.english: "Complete 8 hours of work in a single day", .chinese: "在一天内完成8小时的工作"],
            "Accumulate 100 hours of work time": [.english: "Accumulate 100 hours of work time", .chinese: "累积100小时的工作时间"],
            "Track activity for 7 consecutive days": [.english: "Track activity for 7 consecutive days", .chinese: "连续7天跟踪活动"],
            "Track activity for 30 days": [.english: "Track activity for 30 days", .chinese: "跟踪活动30天"],
            "Use 10 different applications": [.english: "Use 10 different applications", .chinese: "使用10个不同的应用程序"],
            "Use 5 different apps in a single day": [.english: "Use 5 different apps in a single day", .chinese: "在一天内使用5个不同的应用"],
            "Start working before 7 AM": [.english: "Start working before 7 AM", .chinese: "早上7点前开始工作"],
            "Work past midnight": [.english: "Work past midnight", .chinese: "工作到午夜过后"],
            "Achieve 50/50 work-life balance in a day": [.english: "Achieve 50/50 work-life balance in a day", .chinese: "一天内实现50/50的工作生活平衡"],
            "Exceed your daily work goal by 20%": [.english: "Exceed your daily work goal by 20%", .chinese: "超过您的每日工作目标20%"],
            // New strings for Pacering view
            "Focus Time": [.english: "Focus Time", .chinese: "专注时间"],
            "Breaks Taken": [.english: "Breaks Taken", .chinese: "休息次数"],
            "Longest Session": [.english: "Longest Session", .chinese: "最长会话"],
            "Productivity Insights": [.english: "Productivity Insights", .chinese: "生产力洞察"],
            "Most productive hour: ": [.english: "Most productive hour: ", .chinese: "最高效时段："],
            "Work/Life balance: ": [.english: "Work/Life balance: ", .chinese: "工作生活平衡："],
            "Daily Goal": [.english: "Daily Goal", .chinese: "每日目标"],
            "专注": [.english: "Focus", .chinese: "专注"],
            "最长会话": [.english: "Longest Session", .chinese: "最长会话"],
            "休息次数": [.english: "Breaks", .chinese: "休息次数"],
            "生产力": [.english: "Productivity", .chinese: "生产力"],
            "今日活动": [.english: "Today's Activity", .chinese: "今日活动"],
            "30天": [.english: "30 Days", .chinese: "30天"],
            "每日目标": [.english: "Daily Goal", .chinese: "每日目标"],
            "今天": [.english: "Today", .chinese: "今天"],
            "51秒": [.english: "51 sec", .chinese: "51秒"],
            "30秒": [.english: "30 sec", .chinese: "30秒"],
            "Context switches: ": [.english: "Context switches: ", .chinese: "上下文切换："],
            "% work": [.english: "% work", .chinese: "% 工作"],
            // Work Apps view strings
            "Show Most Used": [.english: "Show Most Used", .chinese: "显示最常用"],
            "Show All Apps": [.english: "Show All Apps", .chinese: "显示所有应用"],
            "ACTIVE": [.english: "ACTIVE", .chinese: "活跃"]
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
                                .foregroundColor(.fallbackPrimary)
                            
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
                                    .foregroundColor(.fallbackPrimary)
                                
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
                                .fill(Color.fallbackPrimary.opacity(0.05))
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
                                .foregroundColor(selectedView == "Today" ? .white : .fallbackPrimary)
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
                                .fill(selectedView == "Today" ? Color.fallbackPrimary : Color.clear)
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(value: "Pacering") {
                        HStack(spacing: 12) {
                            Image(systemName: "chart.pie.fill")
                                .foregroundColor(selectedView == "Pacering" ? .white : .fallbackPrimary)
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
                                .fill(selectedView == "Pacering" ? Color.fallbackPrimary : Color.clear)
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(value: "Profile") {
                        HStack(spacing: 12) {
                            Image(systemName: "person.fill")
                                .foregroundColor(selectedView == "Profile" ? .white : .fallbackPrimary)
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
                                .fill(selectedView == "Profile" ? Color.fallbackPrimary : Color.clear)
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(value: "Work Apps") {
                        HStack(spacing: 12) {
                            Image(systemName: "briefcase.fill")
                                .foregroundColor(selectedView == "Work Apps" ? .white : .fallbackPrimary)
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
                                .fill(selectedView == "Work Apps" ? Color.fallbackPrimary : Color.clear)
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(value: "AI Analysis") {
                        HStack(spacing: 12) {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(selectedView == "AI Analysis" ? .white : .fallbackPrimary)
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
                                .fill(selectedView == "AI Analysis" ? Color.fallbackPrimary : Color.clear)
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(value: "Achievements") {
                        HStack(spacing: 12) {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(selectedView == "Achievements" ? .white : .fallbackPrimary)
                                .frame(width: 20)
                            
                            Text("Achievements".localized(languageManager.currentLanguage))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedView == "Achievements" ? .white : .primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedView == "Achievements" ? Color.fallbackPrimary : Color.clear)
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .buttonStyle(PlainButtonStyle())
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 16)
                .navigationSplitViewColumnWidth(250)
                
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
                                .foregroundColor(.fallbackPrimary)
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
            .background(Color.fallbackSidebarBg)
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
            case "Achievements":
                AchievementsView(activityLogger: activityLogger, languageManager: languageManager)
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
                                    .foregroundColor(isCurrentHour ? Color.fallbackPrimary : .secondary)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                
                                Spacer()
                                
                                if isCurrentHour {
                                    Circle()
                                        .fill(Color.fallbackPrimary)
                                        .frame(width: 8, height: 8)
                                        .padding(.trailing, 16)
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isCurrentHour ? Color.fallbackPrimary.opacity(0.05) : Color.clear)
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
                                                      Color.fallbackPrimary.opacity(0.1) : Color.gray.opacity(0.1))
                                                .frame(width: 6, height: 20)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(record.application)
                                                    .font(.system(size: 13, weight: .medium))
                                                    .foregroundColor(activityLogger.workApps.contains(record.application) ? 
                                                                   Color.fallbackPrimary : .primary)
                                                
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
                                                    .foregroundColor(Color.fallbackPrimary)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color.fallbackCardBg)
                                                .subtleShadow()
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
        .background(Color.fallbackMainBg)
    }
}

struct PaceringView: View {
    @ObservedObject var activityLogger: ActivityLogger
    @ObservedObject var languageManager: LanguageManager
    @State private var progressFraction: Double = 0.0
    @State private var selectedTimeRange: String = "Today"
    
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
    
    private func getProductivityStats() -> (focusTime: String, breaks: Int, longestSession: String) {
        let records = activityLogger.getRecordsForCurrentSession()
        let workRecords = records.filter { activityLogger.workApps.contains($0.application) }
        
        let totalFocusSeconds = workRecords.reduce(0) { $0 + $1.durationInSeconds }
        let focusTime = formatDuration(totalFocusSeconds, language: languageManager.currentLanguage)
        
        var breaks = 0
        var previousEndTime: Date?
        for record in workRecords.sorted(by: { $0.startTime < $1.startTime }) {
            if let prevEnd = previousEndTime {
                let breakDuration = record.startTime.timeIntervalSince(prevEnd)
                if breakDuration > 300 { // 5 minutes break
                    breaks += 1
                }
            }
            previousEndTime = record.endTime
        }
        
        let longestSessionSeconds = workRecords.map { $0.durationInSeconds }.max() ?? 0
        let longestSession = formatDuration(longestSessionSeconds, language: languageManager.currentLanguage)
        
        return (focusTime, breaks, longestSession)
    }
    
    private func calculateTodayProgress() -> Double {
        // Use the same logic as the main progress circle
        let workApps = activityLogger.workApps
        let totalWorkSeconds = activityLogger.getRecordsForCurrentSession()
            .filter { workApps.contains($0.application) }
            .reduce(0) { $0 + $1.durationInSeconds }
        let totalWorkHours = Double(totalWorkSeconds) / 3600
        
        let todayString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let todayGoal = activityLogger.dailyGoals[todayString] ?? activityLogger.currentGoal
        return min(1, totalWorkHours / todayGoal)
    }

    var body: some View {
        let stats = getProductivityStats()
        
        GeometryReader { geometry in
            HStack(spacing: 24) {
                // Main content area
                VStack(spacing: 20) {
                    // Top section with ring and stats
                    HStack(spacing: 30) {
                        // Big ring (top left)
                        ZStack {
                            Circle()
                                .stroke(lineWidth: 30)
                                .opacity(0.1)
                                .foregroundColor(Color.fallbackPrimary)
                            
                            PartialCircle(progress: progressFraction)
                                .stroke(style: StrokeStyle(lineWidth: 30, lineCap: .round))
                                .foregroundColor(Color.fallbackPrimary)
                                .rotationEffect(.degrees(-90))
                            
                            // Progress content
                            VStack(spacing: 8) {
                                Text("\(Int(progressFraction * 100))%")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(Color.fallbackPrimary)
                                
                                Text("每日目标".localized(languageManager.currentLanguage))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(width: 280, height: 280)
                        .onAppear {
                            updateProgress()
                        }
                        .onReceive(activityLogger.$records
                            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)) { _ in
                            updateProgress()
                        }
                        
                        // Stats grid (top right)
                        VStack(spacing: 20) {
                            HStack(spacing: 30) {
                                // Focus stats
                                VStack(spacing: 6) {
                                    Text("专注".localized(languageManager.currentLanguage))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                    Text(stats.focusTime)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(Color.fallbackPrimary)
                                    Text("51秒".localized(languageManager.currentLanguage))
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                                .frame(width: 120)
                                
                                // Longest session
                                VStack(spacing: 6) {
                                    Text("最长会话".localized(languageManager.currentLanguage))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                    Text(stats.longestSession)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(Color.fallbackPrimary)
                                    Text("30秒".localized(languageManager.currentLanguage))
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                                .frame(width: 120)
                            }
                            
                            HStack(spacing: 30) {
                                // Breaks
                                VStack(spacing: 6) {
                                    Text("休息次数".localized(languageManager.currentLanguage))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                    Text("\(stats.breaks)")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(Color.orange)
                                }
                                .frame(width: 120)
                                
                                // Productivity
                                VStack(spacing: 6) {
                                    let totalSeconds = activityLogger.getRecordsForCurrentSession()
                                        .reduce(0) { $0 + $1.durationInSeconds }
                                    let workSeconds = activityLogger.getRecordsForCurrentSession()
                                        .filter { activityLogger.workApps.contains($0.application) }
                                        .reduce(0) { $0 + $1.durationInSeconds }
                                    let workPercentage = totalSeconds > 0 ? Int((Double(workSeconds) / Double(totalSeconds)) * 100) : 0
                                    
                                    Text("生产力".localized(languageManager.currentLanguage))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                    Text("\(workPercentage)%")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(Color.green)
                                }
                                .frame(width: 120)
                            }
                        }
                    }
                    
                    // Bottom section - Today's Activity
                    VStack(alignment: .leading, spacing: 16) {
                        Text("今日活动".localized(languageManager.currentLanguage))
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color.fallbackPrimary)
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(activityLogger.summarizeActivity()
                                            .sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                                    HStack(spacing: 12) {
                                        // App name and duration
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(key)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(activityLogger.workApps.contains(key) ? 
                                                               Color.fallbackPrimary : .primary)
                                                .lineLimit(1)
                                            
                                            Text(formatDuration(value, language: languageManager.currentLanguage))
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(minWidth: 120, alignment: .leading)
                                        
                                        // Progress bar
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.gray.opacity(0.1))
                                                .frame(height: 28)
                                            
                                            let maxValue = activityLogger.summarizeActivity().values.max() ?? 1
                                            let percentage = CGFloat(value) / CGFloat(maxValue)
                                            
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(activityLogger.workApps.contains(key) ? 
                                                      Color.fallbackPrimary.opacity(0.3) : Color.gray.opacity(0.2))
                                                .frame(width: max(0, (geometry.size.width - 250) * percentage * 0.7), height: 28)
                                        }
                                        
                                        // Work app indicator
                                        if activityLogger.workApps.contains(key) {
                                            Image(systemName: "briefcase.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color.fallbackPrimary)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.fallbackCardBg)
                                            .subtleShadow()
                                    )
                                }
                            }
                        }
                        .frame(maxHeight: 300)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.fallbackCardBg)
                            .cardShadow()
                    )
                }
                .frame(maxWidth: .infinity)
                
                // Right column - 30-day progress
                VStack(alignment: .leading, spacing: 16) {
                    Text("30天".localized(languageManager.currentLanguage))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.fallbackPrimary)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 10) {
                            // Today's progress at the top
                            let todayProgress = calculateTodayProgress()
                            HStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .stroke(lineWidth: 4)
                                        .opacity(0.2)
                                        .foregroundColor(Color.gray)
                                    
                                    PartialCircle(progress: todayProgress)
                                        .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                        .foregroundColor(todayProgress >= 1 ? 
                                                       Color.green : Color.fallbackPrimary)
                                        .rotationEffect(.degrees(-90))
                                }
                                .frame(width: 36, height: 36)
                                
                                Text("今天".localized(languageManager.currentLanguage))
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color.fallbackPrimary)
                                
                                Spacer()
                                
                                Text("\(Int(todayProgress * 100))%")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 8)
                            
                            // Past 29 days
                            ForEach(activityLogger.getDailyProgress().dropFirst(), id: \.date) { dailyProgress in
                                HStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .stroke(lineWidth: 4)
                                            .opacity(0.2)
                                            .foregroundColor(Color.gray)
                                        
                                        PartialCircle(progress: dailyProgress.progress)
                                            .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                            .foregroundColor(dailyProgress.progress >= 1 ? 
                                                           Color.green : Color.fallbackPrimary)
                                            .rotationEffect(.degrees(-90))
                                    }
                                    .frame(width: 36, height: 36)
                                    
                                    Text(dailyProgress.date)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(dailyProgress.progress * 100))%")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 8)
                            }
                        }
                    }
                }
                .frame(width: 150)
            }
            .padding(24)
        }
        .background(Color.fallbackMainBg)
    }
    
    private func formatHour(_ hour: Int) -> String {
        let period = hour < 12 ? "AM" : "PM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return String(format: "%d:00 %@", displayHour, period)
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
                            .foregroundColor(Color.fallbackPrimary)
                        
                        Text("Customize your productivity tracking".localized(languageManager.currentLanguage))
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Work Time Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(Color.fallbackPrimary)
                                .frame(width: 20)
                            
                            Text("Daily Work Goal".localized(languageManager.currentLanguage))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.fallbackPrimary)
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
                            .fill(Color.fallbackCardBg)
                            .cardShadow()
                    )

                    // Update Interval Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(Color.fallbackPrimary)
                                .frame(width: 20)
                            
                            Text("Update Interval".localized(languageManager.currentLanguage))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.fallbackPrimary)
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
                            .fill(Color.fallbackCardBg)
                            .cardShadow()
                    )

                    // Launch at Login Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "power")
                                .foregroundColor(Color.fallbackPrimary)
                                .frame(width: 20)
                            
                            Text("Startup".localized(languageManager.currentLanguage))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.fallbackPrimary)
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
                            .fill(Color.fallbackCardBg)
                            .cardShadow()
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
                            .fill(Color.fallbackCardBg)
                            .cardShadow()
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background(Color.fallbackMainBg)
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
