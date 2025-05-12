import Foundation

class AIService {
    static let shared = AIService()
    
    // OpenAI API key - replace with your actual API key in production
    // In a real app, this should be stored securely, not hardcoded
    private let apiKey = "YOUR_OPENAI_API_KEY"
    private let apiURL = "https://api.openai.com/v1/chat/completions"
    
    private init() {}
    
    // MARK: - Article Summarization
    func summarizeArticle(title: String, content: String) async throws -> String {
        let prompt = """
        Summarize the following news article in 2-3 concise sentences that capture the key points:
        
        Title: \(title)
        
        Content: \(content)
        """
        
        return try await generateText(prompt: prompt, maxTokens: 150)
    }
    
    // MARK: - Sentiment Analysis
    func analyzeSentiment(title: String, content: String) async throws -> String {
        let prompt = """
        Analyze the sentiment of the following news article and respond with exactly one word: "positive", "negative", or "neutral".
        
        Title: \(title)
        
        Content: \(content)
        """
        
        return try await generateText(prompt: prompt, maxTokens: 10)
    }
    
    // MARK: - OpenAI API Communication
    private func generateText(prompt: String, maxTokens: Int = 100) async throws -> String {
        guard let url = URL(string: apiURL) else {
            throw NSError(domain: "AIService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a concise news assistant that provides accurate summaries."],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": maxTokens,
            "temperature": 0.3
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "AIService", code: 2, userInfo: [NSLocalizedDescriptionKey: "API error: \(errorMessage)"])
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let first = choices.first,
              let message = first["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw NSError(domain: "AIService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
} 