import Foundation

struct NewsArticle: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let url: String
    let imageUrl: String?
    let source: String
    let publishedAt: Date
}

extension NewsArticle {
    static let placeholder = NewsArticle(
        title: "Loading...",
        description: "Loading description...",
        url: "",
        imageUrl: nil,
        source: "Source",
        publishedAt: Date()
    )
} 