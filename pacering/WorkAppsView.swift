import SwiftUI
import AppKit

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.startIndex
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xff0000) >> 16) / 255.0
        let g = Double((rgbValue & 0xff00) >> 8) / 255.0
        let b = Double(rgbValue & 0xff) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

struct WorkAppsView: View {
    @ObservedObject var activityLogger: ActivityLogger
    @ObservedObject var languageManager: LanguageManager
    @State private var allApps: [String] = []
    @State private var selectedWorkApps: Set<String> = []
    @State private var searchText: String = ""

    init(activityLogger: ActivityLogger, languageManager: LanguageManager) {
        self.activityLogger = activityLogger
        self.languageManager = languageManager
        _selectedWorkApps = State(initialValue: Set(activityLogger.workApps))
        fetchInstalledApps()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header Section
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Work Applications".localized(languageManager.currentLanguage))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "012379"))
                    
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
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Apps List
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(allApps.filter { searchText.isEmpty || $0.lowercased().contains(searchText.lowercased()) }, id: \.self) { app in
                        HStack {
                            // App selection indicator
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(selectedWorkApps.contains(app) ? 
                                           Color(hex: "012379") : Color.gray.opacity(0.3), lineWidth: 2)
                                    .frame(width: 22, height: 22)
                                
                                if selectedWorkApps.contains(app) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(Color(hex: "012379"))
                                }
                            }
                            
                            // App icon placeholder
                            RoundedRectangle(cornerRadius: 6)
                                .fill(selectedWorkApps.contains(app) ? 
                                      Color(hex: "012379").opacity(0.1) : Color.gray.opacity(0.1))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "app.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(selectedWorkApps.contains(app) ? 
                                                       Color(hex: "012379") : .secondary)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(app)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(selectedWorkApps.contains(app) ? 
                                                   Color(hex: "012379") : .primary)
                                
                                if selectedWorkApps.contains(app) {
                                    Text("Work App".localized(languageManager.currentLanguage))
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(Color(hex: "012379"))
                                } else {
                                    Text("Personal App".localized(languageManager.currentLanguage))
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            // Work app badge
                            if selectedWorkApps.contains(app) {
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
                                        .fill(Color(hex: "012379"))
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if selectedWorkApps.contains(app) {
                                    selectedWorkApps.remove(app)
                                } else {
                                    selectedWorkApps.insert(app)
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
                
                Button(action: saveWorkApps) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 14))
                        Text("Save Work Apps".localized(languageManager.currentLanguage))
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "012379"))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 20)
            .background(Color.white)
        }
        .background(Color(NSColor.controlBackgroundColor))
        .onAppear {
            fetchInstalledApps()
        }
    }

    private func fetchInstalledApps() {
        let workspace = NSWorkspace.shared
        let apps = workspace.runningApplications.compactMap { $0.localizedName }
        DispatchQueue.main.async {
            self.allApps = apps.sorted()
        }
    }

    private func saveWorkApps() {
        activityLogger.updateWorkApps(Array(selectedWorkApps))
    }
}
