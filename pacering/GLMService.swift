import Foundation
import Combine

class GLMService: ObservableObject {
    private let apiKey = "4a4b4f0a035947afad5c37753da3255c.TRlWSbpVYfpA1Zf3"
    private let baseURL = "https://open.bigmodel.cn/api/paas/v4/chat/completions"
    private let model = "glm-4-flash"
    
    @Published var isLoading = false
    @Published var analysisResult: String = ""
    @Published var analysisResultChinese: String = ""
    @Published var errorMessage: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    func analyzeActivityData(_ activityRecords: [ActivityRecord]) {
        isLoading = true
        errorMessage = ""
        
        // Generate both English and Chinese analysis
        generateBilingualAnalysis(activityRecords)
    }
    
    private func generateBilingualAnalysis(_ activityRecords: [ActivityRecord]) {
        let group = DispatchGroup()
        var englishResult = ""
        var chineseResult = ""
        var hasError = false
        
        // Generate English analysis
        group.enter()
        let englishPrompt = generatePrompt(from: activityRecords, language: .english)
        makeAPIRequest(prompt: englishPrompt) { result in
            switch result {
            case .success(let response):
                englishResult = response
            case .failure(let error):
                hasError = true
                self.errorMessage = "English analysis failed: \(error.localizedDescription)"
            }
            group.leave()
        }
        
        // Generate Chinese analysis
        group.enter()
        let chinesePrompt = generatePrompt(from: activityRecords, language: .chinese)
        makeAPIRequest(prompt: chinesePrompt) { result in
            switch result {
            case .success(let response):
                chineseResult = response
            case .failure(let error):
                if !hasError {
                    hasError = true
                    self.errorMessage = "Chinese analysis failed: \(error.localizedDescription)"
                }
            }
            group.leave()
        }
        
        // Wait for both requests to complete
        group.notify(queue: .main) {
            self.isLoading = false
            if !hasError {
                self.analysisResult = englishResult
                self.analysisResultChinese = chineseResult
            }
        }
    }
    
    private func makeAPIRequest(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        let requestBody = GLMRequest(
            model: model,
            messages: [
                GLMMessage(role: "user", content: prompt)
            ],
            temperature: 0.7,
            max_tokens: 1000
        )
        
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "GLMService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "GLMService", code: 2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(GLMResponse.self, from: data)
                if let choice = response.choices.first {
                    completion(.success(choice.message.content))
                } else {
                    completion(.failure(NSError(domain: "GLMService", code: 3, userInfo: [NSLocalizedDescriptionKey: "No analysis result received"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func generatePrompt(from records: [ActivityRecord], language: AppLanguage = .english) -> String {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        
        let todayString = formatter.string(from: today)
        
        // Filter records for today
        let todayRecords = records.filter { Calendar.current.isDate($0.startTime, inSameDayAs: today) }
        
        // Calculate total active time
        let totalActiveSeconds = todayRecords.reduce(0) { $0 + $1.durationInSeconds }
        let totalActiveHours = Double(totalActiveSeconds) / 3600.0
        
        // Group by application
        var appUsage: [String: Int] = [:]
        for record in todayRecords {
            appUsage[record.application, default: 0] += record.durationInSeconds
        }
        
        // Sort by usage time
        let sortedApps = appUsage.sorted { $0.value > $1.value }
        
        // Calculate work apps time
        let workApps = todayRecords.first?.workApps ?? []
        let workTimeSeconds = todayRecords.filter { workApps.contains($0.application) }.reduce(0) { $0 + $1.durationInSeconds }
        let workTimeHours = Double(workTimeSeconds) / 3600.0
        
        // Build detailed usage breakdown
        let appBreakdown = sortedApps.map { app, seconds in
            let hours = Double(seconds) / 3600.0
            let minutes = (seconds % 3600) / 60
            let isWorkApp = workApps.contains(app)
            return "- \(app): \(String(format: "%.1f", hours))h (\(minutes)m) \(isWorkApp ? "[Work App]" : "[Personal]")"
        }.joined(separator: "\n")
        
        if language == .english {
            return """
            Please analyze my productivity data for \(todayString) and provide a fun, engaging, and insightful summary. Here's my activity data:

            ## 📊 Overall Statistics:
            - **Total Active Time:** \(String(format: "%.1f", totalActiveHours)) hours
            - **Work Time:** \(String(format: "%.1f", workTimeHours)) hours
            - **Personal Time:** \(String(format: "%.1f", totalActiveHours - workTimeHours)) hours
            - **Number of Applications Used:** \(appUsage.count)

            ## 📱 Application Usage Breakdown:
            \(appBreakdown)

            ## 🎯 Work Applications:
            \(workApps.joined(separator: ", "))

            Please provide a fun and engaging analysis in **markdown format** that includes:
            1. **A catchy title or emoji-rich summary**
            2. **Key insights about my productivity patterns**
            3. **Most productive hours/applications**
            4. **Balance between work and personal time**
            5. **Fun observations or gentle suggestions for improvement**
            6. **A motivational closing remark**

            Make it personal, encouraging, and slightly humorous while being informative. Use emojis, bullet points, and proper markdown formatting to make it more engaging!
            """
        } else {
            return """
            请分析我在\(todayString)的工作效率数据，并提供一个有趣、引人入胜且富有洞察力的总结。以下是我的活动数据：

            ## 📊 总体统计：
            - **总活跃时间：** \(String(format: "%.1f", totalActiveHours)) 小时
            - **工作时间：** \(String(format: "%.1f", workTimeHours)) 小时
            - **个人时间：** \(String(format: "%.1f", totalActiveHours - workTimeHours)) 小时
            - **使用的应用程序数量：** \(appUsage.count)

            ## 📱 应用程序使用详情：
            \(appBreakdown)

            ## 🎯 工作应用程序：
            \(workApps.joined(separator: ", "))

            请提供一个有趣且引人入胜的**markdown格式**分析，包括：
            1. **吸引人的标题或富含表情符号的摘要**
            2. **关于我的工作效率模式的关键洞察**
            3. **最高效的时间段/应用程序**
            4. **工作与个人时间的平衡**
            5. **有趣的观察或温和的改进建议**
            6. **激励性的结尾语**

            请用个人化、鼓励性和略带幽默的方式提供信息。使用表情符号、项目符号和适当的markdown格式使其更具吸引力！
            """
        }
    }
}

// MARK: - GLM API Models
struct GLMRequest: Codable {
    let model: String
    let messages: [GLMMessage]
    let temperature: Double
    let max_tokens: Int
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case max_tokens = "max_tokens"
    }
}

struct GLMMessage: Codable {
    let role: String
    let content: String
}

struct GLMResponse: Codable {
    let choices: [GLMChoice]
    let usage: GLMUsage?
}

struct GLMChoice: Codable {
    let message: GLMMessage
    let finish_reason: String?
    
    enum CodingKeys: String, CodingKey {
        case message
        case finish_reason = "finish_reason"
    }
}

struct GLMUsage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
    
    enum CodingKeys: String, CodingKey {
        case prompt_tokens = "prompt_tokens"
        case completion_tokens = "completion_tokens"
        case total_tokens = "total_tokens"
    }
}