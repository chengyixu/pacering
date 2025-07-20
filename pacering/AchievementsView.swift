import SwiftUI

struct Achievement {
    let id: String
    let icon: String
    let title: String
    let description: String
    let progress: Double
    let isUnlocked: Bool
    let category: AchievementCategory
}

enum AchievementCategory {
    case productivity
    case consistency
    case exploration
    case milestones
    case special
}

struct AchievementsView: View {
    @ObservedObject var activityLogger: ActivityLogger
    @ObservedObject var languageManager: LanguageManager
    @State private var selectedCategory: AchievementCategory? = nil
    @State private var achievements: [Achievement] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "012379"))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Achievements".localized(languageManager.currentLanguage))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "012379"))
                        
                        Text("Track your productivity milestones".localized(languageManager.currentLanguage))
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Stats
                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Text("\(achievements.filter { $0.isUnlocked }.count)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(hex: "012379"))
                            Text("Unlocked".localized(languageManager.currentLanguage))
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(achievements.count)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.secondary)
                            Text("Total".localized(languageManager.currentLanguage))
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "012379").opacity(0.05))
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryButton(
                            title: "All".localized(languageManager.currentLanguage),
                            isSelected: selectedCategory == nil,
                            action: { selectedCategory = nil }
                        )
                        
                        CategoryButton(
                            title: "Productivity".localized(languageManager.currentLanguage),
                            isSelected: selectedCategory == .productivity,
                            action: { selectedCategory = .productivity }
                        )
                        
                        CategoryButton(
                            title: "Consistency".localized(languageManager.currentLanguage),
                            isSelected: selectedCategory == .consistency,
                            action: { selectedCategory = .consistency }
                        )
                        
                        CategoryButton(
                            title: "Exploration".localized(languageManager.currentLanguage),
                            isSelected: selectedCategory == .exploration,
                            action: { selectedCategory = .exploration }
                        )
                        
                        CategoryButton(
                            title: "Milestones".localized(languageManager.currentLanguage),
                            isSelected: selectedCategory == .milestones,
                            action: { selectedCategory = .milestones }
                        )
                        
                        CategoryButton(
                            title: "Special".localized(languageManager.currentLanguage),
                            isSelected: selectedCategory == .special,
                            action: { selectedCategory = .special }
                        )
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            // Achievements Grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(filteredAchievements, id: \.id) { achievement in
                        AchievementCard(achievement: achievement, languageManager: languageManager)
                    }
                }
                .padding(20)
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .onAppear {
            updateAchievements()
        }
        .onReceive(activityLogger.$records) { _ in
            updateAchievements()
        }
    }
    
    private var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return achievements.filter { $0.category == category }
        }
        return achievements
    }
    
    private func updateAchievements() {
        achievements = calculateAchievements()
    }
    
    private func calculateAchievements() -> [Achievement] {
        var achievementsList: [Achievement] = []
        
        let allRecords = activityLogger.records
        let todayRecords = allRecords.filter { Calendar.current.isDate($0.startTime, inSameDayAs: Date()) }
        let workRecords = allRecords.filter { activityLogger.workApps.contains($0.application) }
        
        // Calculate various stats
        let totalDays = Set(allRecords.map { Calendar.current.startOfDay(for: $0.startTime) }).count
        let totalHours = allRecords.reduce(0) { $0 + $1.durationInSeconds } / 3600
        let totalApps = Set(allRecords.map { $0.application }).count
        let todayHours = todayRecords.reduce(0) { $0 + $1.durationInSeconds } / 3600
        let workHours = workRecords.reduce(0) { $0 + $1.durationInSeconds } / 3600
        
        // Productivity Achievements
        achievementsList.append(Achievement(
            id: "first_hour",
            icon: "clock.fill",
            title: "First Hour".localized(languageManager.currentLanguage),
            description: "Complete your first hour of tracked activity".localized(languageManager.currentLanguage),
            progress: min(Double(totalHours), 1.0),
            isUnlocked: totalHours >= 1,
            category: .productivity
        ))
        
        achievementsList.append(Achievement(
            id: "workday_warrior",
            icon: "briefcase.fill",
            title: "Workday Warrior".localized(languageManager.currentLanguage),
            description: "Complete 8 hours of work in a single day".localized(languageManager.currentLanguage),
            progress: Double(todayHours) / 8.0,
            isUnlocked: todayHours >= 8,
            category: .productivity
        ))
        
        achievementsList.append(Achievement(
            id: "productivity_master",
            icon: "star.fill",
            title: "Productivity Master".localized(languageManager.currentLanguage),
            description: "Accumulate 100 hours of work time".localized(languageManager.currentLanguage),
            progress: Double(workHours) / 100.0,
            isUnlocked: workHours >= 100,
            category: .productivity
        ))
        
        // Consistency Achievements
        achievementsList.append(Achievement(
            id: "week_streak",
            icon: "flame.fill",
            title: "Week Streak".localized(languageManager.currentLanguage),
            description: "Track activity for 7 consecutive days".localized(languageManager.currentLanguage),
            progress: Double(min(totalDays, 7)) / 7.0,
            isUnlocked: totalDays >= 7,
            category: .consistency
        ))
        
        achievementsList.append(Achievement(
            id: "month_commitment",
            icon: "calendar.badge.checkmark",
            title: "Monthly Commitment".localized(languageManager.currentLanguage),
            description: "Track activity for 30 days".localized(languageManager.currentLanguage),
            progress: Double(min(totalDays, 30)) / 30.0,
            isUnlocked: totalDays >= 30,
            category: .consistency
        ))
        
        // Exploration Achievements
        achievementsList.append(Achievement(
            id: "app_explorer",
            icon: "square.grid.3x3.fill",
            title: "App Explorer".localized(languageManager.currentLanguage),
            description: "Use 10 different applications".localized(languageManager.currentLanguage),
            progress: Double(min(totalApps, 10)) / 10.0,
            isUnlocked: totalApps >= 10,
            category: .exploration
        ))
        
        achievementsList.append(Achievement(
            id: "multitasker",
            icon: "rectangle.split.3x1.fill",
            title: "Multitasker".localized(languageManager.currentLanguage),
            description: "Use 5 different apps in a single day".localized(languageManager.currentLanguage),
            progress: Double(min(Set(todayRecords.map { $0.application }).count, 5)) / 5.0,
            isUnlocked: Set(todayRecords.map { $0.application }).count >= 5,
            category: .exploration
        ))
        
        // Milestone Achievements
        achievementsList.append(Achievement(
            id: "early_bird",
            icon: "sunrise.fill",
            title: "Early Bird".localized(languageManager.currentLanguage),
            description: "Start working before 7 AM".localized(languageManager.currentLanguage),
            progress: hasEarlyMorningActivity() ? 1.0 : 0.0,
            isUnlocked: hasEarlyMorningActivity(),
            category: .milestones
        ))
        
        achievementsList.append(Achievement(
            id: "night_owl",
            icon: "moon.stars.fill",
            title: "Night Owl".localized(languageManager.currentLanguage),
            description: "Work past midnight".localized(languageManager.currentLanguage),
            progress: hasLateNightActivity() ? 1.0 : 0.0,
            isUnlocked: hasLateNightActivity(),
            category: .milestones
        ))
        
        // Special Achievements
        achievementsList.append(Achievement(
            id: "perfect_balance",
            icon: "scale.3d",
            title: "Perfect Balance".localized(languageManager.currentLanguage),
            description: "Achieve 50/50 work-life balance in a day".localized(languageManager.currentLanguage),
            progress: calculateBalanceProgress(),
            isUnlocked: hasAchievedPerfectBalance(),
            category: .special
        ))
        
        achievementsList.append(Achievement(
            id: "goal_crusher",
            icon: "target",
            title: "Goal Crusher".localized(languageManager.currentLanguage),
            description: "Exceed your daily work goal by 20%".localized(languageManager.currentLanguage),
            progress: calculateGoalProgress(),
            isUnlocked: hasExceededGoal(),
            category: .special
        ))
        
        return achievementsList
    }
    
    private func hasEarlyMorningActivity() -> Bool {
        return activityLogger.records.contains { record in
            let hour = Calendar.current.component(.hour, from: record.startTime)
            return hour < 7
        }
    }
    
    private func hasLateNightActivity() -> Bool {
        return activityLogger.records.contains { record in
            let hour = Calendar.current.component(.hour, from: record.startTime)
            return hour >= 0 && hour < 3
        }
    }
    
    private func calculateBalanceProgress() -> Double {
        let todayRecords = activityLogger.records.filter { Calendar.current.isDate($0.startTime, inSameDayAs: Date()) }
        let workTime = todayRecords.filter { activityLogger.workApps.contains($0.application) }.reduce(0) { $0 + $1.durationInSeconds }
        let totalTime = todayRecords.reduce(0) { $0 + $1.durationInSeconds }
        
        guard totalTime > 0 else { return 0.0 }
        
        let workRatio = Double(workTime) / Double(totalTime)
        let balanceScore = 1.0 - abs(workRatio - 0.5) * 2
        return balanceScore
    }
    
    private func hasAchievedPerfectBalance() -> Bool {
        return calculateBalanceProgress() >= 0.9
    }
    
    private func calculateGoalProgress() -> Double {
        let todayWorkTime = activityLogger.records
            .filter { Calendar.current.isDate($0.startTime, inSameDayAs: Date()) && activityLogger.workApps.contains($0.application) }
            .reduce(0) { $0 + $1.durationInSeconds }
        
        let goalSeconds = Int(activityLogger.currentGoal * 3600)
        guard goalSeconds > 0 else { return 0.0 }
        
        return Double(todayWorkTime) / (Double(goalSeconds) * 1.2)
    }
    
    private func hasExceededGoal() -> Bool {
        return calculateGoalProgress() >= 1.0
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : Color(hex: "012379"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color(hex: "012379") : Color(hex: "012379").opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    @ObservedObject var languageManager: LanguageManager
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color(hex: "012379").opacity(0.1) : Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 28))
                    .foregroundColor(achievement.isUnlocked ? Color(hex: "012379") : .gray)
            }
            
            // Title
            Text(achievement.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                .multilineTextAlignment(.center)
            
            // Description
            Text(achievement.description)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 32)
            
            // Progress
            if !achievement.isUnlocked {
                VStack(spacing: 4) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "012379"))
                                .frame(width: geometry.size.width * min(achievement.progress, 1.0), height: 8)
                        }
                    }
                    .frame(height: 8)
                    
                    Text("\(Int(min(achievement.progress, 1.0) * 100))%")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            
            // Unlocked badge
            if achievement.isUnlocked {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                    Text("Unlocked".localized(languageManager.currentLanguage))
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.green)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(achievement.isUnlocked ? 0.06 : 0.02), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(achievement.isUnlocked ? Color(hex: "012379").opacity(0.2) : Color.clear, lineWidth: 1)
        )
    }
}