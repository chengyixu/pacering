import SwiftUI
import AppKit

struct WorkAppsView: View {
    @ObservedObject var activityLogger: ActivityLogger
    @ObservedObject var languageManager: LanguageManager
    @State private var allApps: [(name: String, usage: Int)] = []
    @State private var selectedWorkApps: Set<String> = []
    @State private var searchText: String = ""
    @State private var showAllApps: Bool = false

    init(activityLogger: ActivityLogger, languageManager: LanguageManager) {
        self.activityLogger = activityLogger
        self.languageManager = languageManager
        _selectedWorkApps = State(initialValue: Set(activityLogger.workApps))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header Section
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Work Applications".localized(languageManager.currentLanguage))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.fallbackPrimary)
                    
                    Text("Select which applications should count as work time".localized(languageManager.currentLanguage))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .frame(width: 16)
                    
                    TextField("Search applications...".localized(languageManager.currentLanguage), text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 14))
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.fallbackCardBg)
                        .cardShadow()
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Apps List
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(allApps.filter { app in
                        searchText.isEmpty || app.name.lowercased().contains(searchText.lowercased())
                    }, id: \.name) { app in
                        HStack {
                            // App selection indicator
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(selectedWorkApps.contains(app.name) ? 
                                           Color.fallbackPrimary : Color.gray.opacity(0.3), lineWidth: 2)
                                    .frame(width: 22, height: 22)
                                
                                if selectedWorkApps.contains(app.name) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(Color.fallbackPrimary)
                                }
                            }
                            
                            // App icon placeholder with usage indicator
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(selectedWorkApps.contains(app.name) ? 
                                          Color.fallbackPrimary.opacity(0.1) : Color.gray.opacity(0.1))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "app.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(selectedWorkApps.contains(app.name) ? 
                                                           Color.fallbackPrimary : .secondary)
                                    )
                                
                                // Usage indicator
                                if app.usage > 0 {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 8, height: 8)
                                        .offset(x: 12, y: -12)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(app.name)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(selectedWorkApps.contains(app.name) ? 
                                                       Color.fallbackPrimary : .primary)
                                    
                                    if app.usage > 0 {
                                        Text("• \(formatDuration(app.usage))")
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                if selectedWorkApps.contains(app.name) {
                                    Text("Work App".localized(languageManager.currentLanguage))
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(Color.fallbackPrimary)
                                } else {
                                    Text("Personal App".localized(languageManager.currentLanguage))
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            // Work app badge or usage badge
                            if app.usage > 0 && !selectedWorkApps.contains(app.name) {
                                HStack(spacing: 4) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 10))
                                    Text("ACTIVE".localized(languageManager.currentLanguage))
                                        .font(.system(size: 10, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green)
                                )
                            } else if selectedWorkApps.contains(app.name) {
                                HStack(spacing: 4) {
                                    Image(systemName: "briefcase.fill")
                                        .font(.system(size: 10))
                                    Text("WORK".localized(languageManager.currentLanguage))
                                        .font(.system(size: 10, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.fallbackPrimary)
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.fallbackCardBg)
                                .subtleShadow()
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if selectedWorkApps.contains(app.name) {
                                    selectedWorkApps.remove(app.name)
                                } else {
                                    selectedWorkApps.insert(app.name)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Save Button
            VStack(spacing: 16) {
                // Selected count
                HStack {
                    Text("\(selectedWorkApps.count) \("apps selected as work applications".localized(languageManager.currentLanguage))")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                HStack(spacing: 12) {
                    Button(action: { showAllApps.toggle() }) {
                        HStack {
                            Image(systemName: showAllApps ? "eye.slash" : "eye")
                                .font(.system(size: 14))
                            Text(showAllApps ? "Show Most Used".localized(languageManager.currentLanguage) : "Show All Apps".localized(languageManager.currentLanguage))
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(Color.fallbackPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.fallbackPrimary, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: saveWorkApps) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 14))
                            Text("Save Work Apps".localized(languageManager.currentLanguage))
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.fallbackPrimary)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 20)
            .background(Color.fallbackCardBg)
        }
        .background(Color.fallbackMainBg)
        .onAppear {
            updateAppsList()
        }
        .onReceive(activityLogger.$records
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)) { _ in
            updateAppsList()
        }
    }

    private func updateAppsList() {
        // Get app usage data
        let appUsage = activityLogger.summarizeActivity()
        
        // Get running applications
        let workspace = NSWorkspace.shared
        var runningApps = Set(workspace.runningApplications.compactMap { $0.localizedName })
        
        // Add apps from usage history
        for appName in appUsage.keys {
            runningApps.insert(appName)
        }
        
        // Create app list with usage data
        var appsList: [(name: String, usage: Int)] = []
        
        for appName in runningApps {
            let usage = appUsage[appName] ?? 0
            appsList.append((name: appName, usage: usage))
        }
        
        // Sort by usage (most used first) or alphabetically if showing all
        DispatchQueue.main.async {
            if self.showAllApps {
                self.allApps = appsList.sorted { $0.name < $1.name }
            } else {
                // Show only apps with usage or that are marked as work apps
                self.allApps = appsList
                    .filter { $0.usage > 0 || self.selectedWorkApps.contains($0.name) }
                    .sorted { $0.usage > $1.usage }
            }
        }
    }
    
    private func formatDuration(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "<1m"
        }
    }

    private func saveWorkApps() {
        activityLogger.updateWorkApps(Array(selectedWorkApps))
    }
}
