import Foundation
import SwiftUI

struct NewsArticle: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let url: String
    let imageUrl: String?
    let source: String
    let publishedAt: Date
    var category: String?
    var summary: String?
    var sentiment: String?
    
    // AI-based category detection
    var detectedCategory: String {
        if category != nil {
            return category!
        }
        
        let categoriesKeywords: [String: [String]] = [
            "Politics": ["politics", "government", "election", "minister", "president", "parliament", "democracy"],
            "Sports": ["sports", "cricket", "football", "game", "player", "match", "tournament", "championship", "ipl", "world cup"],
            "Technology": ["technology", "tech", "ai", "software", "digital", "app", "smartphone", "computer", "internet", "gadget"],
            "Business": ["business", "economy", "market", "stock", "finance", "investment", "startup", "company", "corporate"],
            "Entertainment": ["entertainment", "movie", "film", "cinema", "music", "celebrity", "actor", "bollywood", "hollywood"],
            "Health": ["health", "medical", "doctor", "disease", "hospital", "covid", "treatment", "medicine", "vaccine"],
            "Science": ["science", "research", "discovery", "space", "nasa", "scientist", "study", "experiment"]
        ]
        
        let lowerTitle = title.lowercased()
        let lowerDesc = description.lowercased()
        let combinedText = lowerTitle + " " + lowerDesc
        
        var bestMatch = "General"
        var highestCount = 0
        
        for (category, keywords) in categoriesKeywords {
            let count = keywords.reduce(0) { acc, keyword in
                acc + (combinedText.contains(keyword) ? 1 : 0)
            }
            
            if count > highestCount {
                highestCount = count
                bestMatch = category
            }
        }
        
        return highestCount > 0 ? bestMatch : "General"
    }
    
    // Get sentiment color
    var sentimentColor: Color {
        switch sentiment?.lowercased() {
        case "positive":
            return .green.opacity(0.8)
        case "negative":
            return .red.opacity(0.8)
        case "neutral":
            return .gray.opacity(0.8)
        default:
            return .gray.opacity(0.5)
        }
    }
}

extension NewsArticle {
    static let placeholder = NewsArticle(
        title: "Loading...",
        description: "Loading description...",
        url: "",
        imageUrl: nil,
        source: "Source",
        publishedAt: Date(),
        category: nil,
        summary: nil,
        sentiment: nil
    )
} 