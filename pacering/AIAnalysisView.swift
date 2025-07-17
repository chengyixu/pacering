import SwiftUI

struct AIAnalysisView: View {
    @ObservedObject var activityLogger: ActivityLogger
    @ObservedObject var languageManager: LanguageManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "012379"))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI Analysis")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "012379"))
                        
                        Text("Intelligent insights about your productivity")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        activityLogger.generateAIAnalysis()
                    }) {
                        HStack(spacing: 8) {
                            if activityLogger.glmService.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 14))
                            }
                            
                            Text(activityLogger.glmService.isLoading ? "Analyzing..." : "Generate Analysis")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "012379"))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(activityLogger.glmService.isLoading)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            
            // Content Area
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Analysis Result
                    if !activityLogger.glmService.analysisResult.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "text.bubble.fill")
                                    .foregroundColor(Color(hex: "012379"))
                                    .font(.system(size: 16))
                                
                                Text("AI Insights")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(hex: "012379"))
                                
                                Spacer()
                                
                                Text(formatCurrentTime())
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(activityLogger.glmService.analysisResult)
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                                .lineSpacing(4)
                                .textSelection(.enabled)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: "012379").opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(hex: "012379").opacity(0.1), lineWidth: 1)
                                        )
                                )
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                        )
                    }
                    
                    // Error Message
                    if !activityLogger.glmService.errorMessage.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 16))
                                
                                Text("Error")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.red)
                            }
                            
                            Text(activityLogger.glmService.errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.red.opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.red.opacity(0.2), lineWidth: 1)
                                        )
                                )
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                        )
                    }
                    
                    // Empty State
                    if activityLogger.glmService.analysisResult.isEmpty && activityLogger.glmService.errorMessage.isEmpty && !activityLogger.glmService.isLoading {
                        VStack(spacing: 16) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 48))
                                .foregroundColor(Color(hex: "012379").opacity(0.3))
                            
                            VStack(spacing: 8) {
                                Text("Ready for AI Analysis")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(hex: "012379"))
                                
                                Text("Click the 'Generate Analysis' button to get intelligent insights about your productivity patterns")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(nil)
                            }
                            
                            // Quick stats preview
                            if !activityLogger.records.isEmpty {
                                VStack(spacing: 12) {
                                    Text("Today's Activity Preview")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(hex: "012379"))
                                    
                                    let todayRecords = activityLogger.records.filter { Calendar.current.isDate($0.startTime, inSameDayAs: Date()) }
                                    let totalApps = Set(todayRecords.map { $0.application }).count
                                    let totalTime = todayRecords.reduce(0) { $0 + $1.durationInSeconds }
                                    let hours = totalTime / 3600
                                    let minutes = (totalTime % 3600) / 60
                                    
                                    HStack(spacing: 24) {
                                        VStack(spacing: 4) {
                                            Text("\(totalApps)")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(Color(hex: "012379"))
                                            Text("Apps Used")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        VStack(spacing: 4) {
                                            Text("\(hours)h \(minutes)m")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(Color(hex: "012379"))
                                            Text("Total Time")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(hex: "012379").opacity(0.05))
                                    )
                                }
                            }
                        }
                        .padding(.vertical, 40)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .onAppear {
            // Auto-generate analysis if there's activity data and no existing analysis
            if !activityLogger.records.isEmpty && 
               activityLogger.glmService.analysisResult.isEmpty && 
               !activityLogger.glmService.isLoading {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    activityLogger.generateAIAnalysis()
                }
            }
        }
    }
    
    private func formatCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}

