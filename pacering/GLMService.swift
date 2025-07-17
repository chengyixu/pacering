import Foundation
import Combine

class GLMService: ObservableObject {
    private let apiKey = "4a4b4f0a035947afad5c37753da3255c.TRlWSbpVYfpA1Zf3"
    private let baseURL = "https://open.bigmodel.cn/api/paas/v4/chat/completions"
    private let model = "glm-4-flash"
    
    @Published var isLoading = false
    @Published var analysisResult: String = ""
    @Published var errorMessage: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    func analyzeActivityData(_ activityRecords: [ActivityRecord]) {
        isLoading = true
        errorMessage = ""
        
        let prompt = generatePrompt(from: activityRecords)
        
        let requestBody = GLMRequest(
            model: model,
            messages: [
                GLMMessage(role: "user", content: prompt)
            ],
            temperature: 0.7,
            max_tokens: 1000
        )
        
        guard let url = URL(string: baseURL) else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Invalid URL"
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Error encoding request: \(error.localizedDescription)"
            }
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: GLMResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoading = false
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self.errorMessage = "Analysis failed: \(error.localizedDescription)"
                    }
                },
                receiveValue: { response in
                    if let choice = response.choices.first {
                        self.analysisResult = choice.message.content
                    } else {
                        self.errorMessage = "No analysis result received"
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func generatePrompt(from records: [ActivityRecord]) -> String {
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
        
        return """
        Please analyze my productivity data for \(todayString) and provide a fun, engaging, and insightful summary. Here's my activity data:

        📊 **Overall Statistics:**
        - Total Active Time: \(String(format: "%.1f", totalActiveHours)) hours
        - Work Time: \(String(format: "%.1f", workTimeHours)) hours
        - Personal Time: \(String(format: "%.1f", totalActiveHours - workTimeHours)) hours
        - Number of Applications Used: \(appUsage.count)

        📱 **Application Usage Breakdown:**
        \(appBreakdown)

        🎯 **Work Applications:** \(workApps.joined(separator: ", "))

        Please provide a fun and engaging analysis that includes:
        1. A catchy title or emoji-rich summary
        2. Key insights about my productivity patterns
        3. Most productive hours/applications
        4. Balance between work and personal time
        5. Fun observations or gentle suggestions for improvement
        6. A motivational closing remark

        Make it personal, encouraging, and slightly humorous while being informative. Use emojis to make it more engaging!
        """
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