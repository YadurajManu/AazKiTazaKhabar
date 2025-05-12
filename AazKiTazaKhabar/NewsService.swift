import Foundation

class NewsService {
    static let shared = NewsService()
    
    // API Keys (replace with your actual keys)
    private let newsApiKey = "5e7bad98b99548c59ef093ed5ef77c70"
    private let mediastackKey = "022b3a27d461560360e504da06c616cd"
    private let gnewsKey = "3bb0c834c30e34c304696a53d14f5bb2"
    // Add Currents API key if you have one
    
    private let newsApiBase = "https://newsapi.org/v2/top-headlines"
    private let mediastackBase = "https://api.mediastack.com/v1/news"
    private let gnewsBase = "https://gnews.io/api/v4/top-headlines"
    // Add Currents API base if needed
    
    private let session = URLSession.shared
    
    // MARK: - Public API
    func fetchAllNews(completion: @escaping ([NewsArticle]) -> Void) {
        let group = DispatchGroup()
        var allArticles: [NewsArticle] = []
        
        group.enter()
        fetchNewsAPI { articles in
            allArticles.append(contentsOf: articles)
            group.leave()
        }
        group.enter()
        fetchMediastack { articles in
            allArticles.append(contentsOf: articles)
            group.leave()
        }
        group.enter()
        fetchGNews { articles in
            allArticles.append(contentsOf: articles)
            group.leave()
        }
        // Add Currents API here if needed
        
        group.notify(queue: .main) {
            // Deduplicate by title
            let unique = Array(Set(allArticles)).sorted { $0.publishedAt > $1.publishedAt }
            // Only articles with images
            let filtered = unique.filter { $0.imageUrl != nil && !$0.imageUrl!.isEmpty }
            completion(filtered)
        }
    }
    
    // MARK: - NewsAPI
    private func fetchNewsAPI(completion: @escaping ([NewsArticle]) -> Void) {
        guard let url = URL(string: "\(newsApiBase)?country=in&apiKey=\(newsApiKey)") else {
            completion([]); return
        }
        session.dataTask(with: url) { data, _, _ in
            guard let data = data else { completion([]); return }
            do {
                let decoded = try JSONDecoder().decode(NewsAPIResponse.self, from: data)
                let articles = decoded.articles.compactMap { $0.toNewsArticle() }
                completion(articles)
            } catch {
                completion([])
            }
        }.resume()
    }
    
    // MARK: - Mediastack
    private func fetchMediastack(completion: @escaping ([NewsArticle]) -> Void) {
        guard let url = URL(string: "\(mediastackBase)?access_key=\(mediastackKey)&countries=in") else {
            completion([]); return
        }
        session.dataTask(with: url) { data, _, _ in
            guard let data = data else { completion([]); return }
            do {
                let decoded = try JSONDecoder().decode(MediastackResponse.self, from: data)
                let articles = decoded.data.compactMap { $0.toNewsArticle() }
                completion(articles)
            } catch {
                completion([])
            }
        }.resume()
    }
    
    // MARK: - GNews
    private func fetchGNews(completion: @escaping ([NewsArticle]) -> Void) {
        guard let url = URL(string: "\(gnewsBase)?country=in&token=\(gnewsKey)") else {
            completion([]); return
        }
        session.dataTask(with: url) { data, _, _ in
            guard let data = data else { completion([]); return }
            do {
                let decoded = try JSONDecoder().decode(GNewsResponse.self, from: data)
                let articles = decoded.articles.compactMap { $0.toNewsArticle() }
                completion(articles)
            } catch {
                completion([])
            }
        }.resume()
    }
}

// MARK: - NewsAPI Models
struct NewsAPIResponse: Codable {
    let articles: [NewsAPIArticle]
}
struct NewsAPIArticle: Codable {
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let source: Source
    let publishedAt: String
    struct Source: Codable { let name: String }
    func toNewsArticle() -> NewsArticle? {
        guard let desc = description else { return nil }
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: publishedAt) ?? Date()
        return NewsArticle(
            title: title,
            description: desc,
            url: url,
            imageUrl: urlToImage,
            source: source.name,
            publishedAt: date
        )
    }
}

// MARK: - Mediastack Models
struct MediastackResponse: Codable {
    let data: [MediastackArticle]
}
struct MediastackArticle: Codable {
    let title: String
    let description: String?
    let url: String
    let image: String?
    let source: String?
    let published_at: String?
    func toNewsArticle() -> NewsArticle? {
        guard let desc = description, let published = published_at else { return nil }
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: published) ?? Date()
        return NewsArticle(
            title: title,
            description: desc,
            url: url,
            imageUrl: image,
            source: source ?? "Mediastack",
            publishedAt: date
        )
    }
}

// MARK: - GNews Models
struct GNewsResponse: Codable {
    let articles: [GNewsArticle]
}
struct GNewsArticle: Codable {
    let title: String
    let description: String?
    let url: String
    let image: String?
    let source: GNewsSource
    let publishedAt: String
    struct GNewsSource: Codable { let name: String }
    func toNewsArticle() -> NewsArticle? {
        guard let desc = description else { return nil }
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: publishedAt) ?? Date()
        return NewsArticle(
            title: title,
            description: desc,
            url: url,
            imageUrl: image,
            source: source.name,
            publishedAt: date
        )
    }
} 