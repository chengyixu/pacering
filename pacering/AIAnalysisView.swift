import SwiftUI

// MARK: - Markdown Parser
struct MarkdownParser {
    static func parse(_ markdown: String) -> [MarkdownElement] {
        var elements: [MarkdownElement] = []
        let lines = markdown.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.isEmpty {
                elements.append(.spacing(8))
                continue
            }
            
            // Headers
            if trimmedLine.hasPrefix("# ") {
                elements.append(.header(String(trimmedLine.dropFirst(2)), level: 1))
            } else if trimmedLine.hasPrefix("## ") {
                elements.append(.header(String(trimmedLine.dropFirst(3)), level: 2))
            } else if trimmedLine.hasPrefix("### ") {
                elements.append(.header(String(trimmedLine.dropFirst(4)), level: 3))
            }
            // Bold text - strip ** markers and treat as regular text
            else if trimmedLine.hasPrefix("**") && trimmedLine.hasSuffix("**") && trimmedLine.count > 4 {
                let boldText = String(trimmedLine.dropFirst(2).dropLast(2))
                elements.append(.text([.text(boldText)]))
            }
            // Bullet points
            else if trimmedLine.hasPrefix("- ") || trimmedLine.hasPrefix("• ") {
                elements.append(.bullet(String(trimmedLine.dropFirst(2))))
            }
            // Numbered lists
            else if let range = trimmedLine.range(of: #"^\d+\.\s"#, options: .regularExpression) {
                let text = String(trimmedLine[range.upperBound...])
                elements.append(.numberedItem(text))
            }
            // Regular text
            else {
                elements.append(.text(parseBoldInline(trimmedLine)))
            }
        }
        
        return elements
    }
    
    private static func parseBoldInline(_ text: String) -> [InlineElement] {
        var elements: [InlineElement] = []
        let parts = text.components(separatedBy: "**")
        
        // Simply join all parts as regular text (removing ** markers)
        let cleanedText = parts.joined()
        
        if !cleanedText.isEmpty {
            elements.append(.text(cleanedText))
        } else if !text.isEmpty {
            elements.append(.text(text))
        }
        
        return elements
    }
}

enum MarkdownElement {
    case header(String, level: Int)
    case text([InlineElement])
    case bold(String)
    case bullet(String)
    case numberedItem(String)
    case spacing(CGFloat)
}

enum InlineElement {
    case text(String)
    case bold(String)
}

struct MarkdownView: View {
    let elements: [MarkdownElement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(elements.enumerated()), id: \.offset) { index, element in
                switch element {
                case .header(let text, let level):
                    headerView(text: text, level: level)
                case .text(let inlineElements):
                    inlineTextView(elements: inlineElements)
                case .bold(let text):
                    Text(text)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 2)
                case .bullet(let text):
                    bulletView(text: text)
                case .numberedItem(let text):
                    numberedItemView(text: text, number: getNumberForItem(index))
                case .spacing(let height):
                    Spacer().frame(height: height)
                }
            }
        }
    }
    
    private func headerView(text: String, level: Int) -> some View {
        let fontSize: CGFloat = level == 1 ? 18 : level == 2 ? 16 : 14
        let fontWeight: Font.Weight = level == 1 ? .bold : level == 2 ? .semibold : .medium
        
        return Text(text)
            .font(.system(size: fontSize, weight: fontWeight))
            .foregroundColor(Color(hex: "012379"))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, level == 1 ? 8 : 6)
    }
    
    private func inlineTextView(elements: [InlineElement]) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(elements.enumerated()), id: \.offset) { _, element in
                switch element {
                case .text(let text):
                    Text(text)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                case .bold(let text):
                    Text(text)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 2)
    }
    
    private func bulletView(text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "012379"))
                .frame(width: 12, alignment: .center)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 2)
    }
    
    private func numberedItemView(text: String, number: Int) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number).")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "012379"))
                .frame(width: 20, alignment: .leading)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 2)
    }
    
    private func getNumberForItem(_ index: Int) -> Int {
        var number = 1
        for i in 0..<index {
            if case .numberedItem = elements[i] {
                number += 1
            }
        }
        return number
    }
}

struct AIAnalysisView: View {
    @ObservedObject var activityLogger: ActivityLogger
    @ObservedObject var languageManager: LanguageManager
    @State private var showCopiedMessage = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "012379"))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI Analysis".localized(languageManager.currentLanguage))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "012379"))
                        
                        Text("Intelligent insights about your productivity".localized(languageManager.currentLanguage))
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
                            
                            Text(activityLogger.glmService.isLoading ? "Analyzing...".localized(languageManager.currentLanguage) : "Generate Analysis".localized(languageManager.currentLanguage))
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
                    let hasEnglishResult = !activityLogger.glmService.analysisResult.isEmpty
                    let hasChineseResult = !activityLogger.glmService.analysisResultChinese.isEmpty
                    
                    if hasEnglishResult || hasChineseResult {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "text.bubble.fill")
                                    .foregroundColor(Color(hex: "012379"))
                                    .font(.system(size: 16))
                                
                                Text("Analysis Results".localized(languageManager.currentLanguage))
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(hex: "012379"))
                                
                                Spacer()
                                
                                // Copy button
                                Button(action: {
                                    let currentResult = languageManager.currentLanguage == .english ? 
                                        activityLogger.glmService.analysisResult : 
                                        activityLogger.glmService.analysisResultChinese
                                    
                                    let pasteboard = NSPasteboard.general
                                    pasteboard.clearContents()
                                    pasteboard.setString(currentResult, forType: .string)
                                    
                                    showCopiedMessage = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        showCopiedMessage = false
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: showCopiedMessage ? "checkmark" : "doc.on.doc")
                                            .font(.system(size: 12))
                                        Text(showCopiedMessage ? "Copied!".localized(languageManager.currentLanguage) : "Copy".localized(languageManager.currentLanguage))
                                            .font(.system(size: 12))
                                    }
                                    .foregroundColor(showCopiedMessage ? .green : Color(hex: "012379"))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(showCopiedMessage ? .green.opacity(0.1) : Color(hex: "012379").opacity(0.1))
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Text(formatCurrentTime())
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            let currentResult = languageManager.currentLanguage == .english ? 
                                activityLogger.glmService.analysisResult : 
                                activityLogger.glmService.analysisResultChinese
                            
                            let markdownElements = MarkdownParser.parse(currentResult)
                            
                            MarkdownView(elements: markdownElements)
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
                                
                                Text("Error".localized(languageManager.currentLanguage))
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
                    if !hasEnglishResult && !hasChineseResult && activityLogger.glmService.errorMessage.isEmpty && !activityLogger.glmService.isLoading {
                        VStack(spacing: 16) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 48))
                                .foregroundColor(Color(hex: "012379").opacity(0.3))
                            
                            VStack(spacing: 8) {
                                Text("Ready for AI Analysis".localized(languageManager.currentLanguage))
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(hex: "012379"))
                                
                                Text("Click the 'Generate Analysis' button to get intelligent insights about your productivity patterns".localized(languageManager.currentLanguage))
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(nil)
                            }
                            
                            // Quick stats preview
                            if !activityLogger.records.isEmpty {
                                VStack(spacing: 12) {
                                    Text("Today's Activity Preview".localized(languageManager.currentLanguage))
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
                                            Text("Apps Used".localized(languageManager.currentLanguage))
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        VStack(spacing: 4) {
                                            Text("\(hours)h \(minutes)m")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(Color(hex: "012379"))
                                            Text("Total Time".localized(languageManager.currentLanguage))
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
               activityLogger.glmService.analysisResultChinese.isEmpty &&
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

