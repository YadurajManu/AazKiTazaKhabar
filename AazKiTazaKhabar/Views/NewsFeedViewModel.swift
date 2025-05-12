import Foundation
import Combine

class NewsFeedViewModel: ObservableObject {
    @Published var articles: [NewsArticle] = []
    @Published var filteredArticles: [NewsArticle] = []
    @Published var isLoading: Bool = false
    @Published var isRefreshing: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedRegion: String = "All"
    @Published var selectedCategory: String = "All"
    @Published var searchText: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupFiltering()
    }
    
    private func setupFiltering() {
        // Create a publisher that combines region, category, and search text
        Publishers.CombineLatest3($selectedRegion, $selectedCategory, $searchText)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] region, category, searchText in
                self?.applyFilters(region: region, category: category, searchText: searchText)
            }
            .store(in: &cancellables)
    }
    
    private func applyFilters(region: String, category: String, searchText: String) {
        var filtered = articles
        
        // Apply region filter
        if region != "All" {
            // This is placeholder logic - adapt based on your actual data model
            filtered = filtered.filter { article in
                if region == "Indian" {
                    return article.source.contains("India") || article.source.lowercased().contains("india")
                } else if region == "Global" {
                    return !article.source.contains("India") && !article.source.lowercased().contains("india")
                }
                return true
            }
        }
        
        // Apply category filter
        if category != "All" {
            // This is placeholder logic - adapt based on your actual data model
            filtered = filtered.filter { article in
                article.title.lowercased().contains(category.lowercased()) ||
                article.description.lowercased().contains(category.lowercased())
            }
        }
        
        // Apply search text filter
        if !searchText.isEmpty {
            filtered = filtered.filter { article in
                article.title.lowercased().contains(searchText.lowercased()) ||
                article.description.lowercased().contains(searchText.lowercased()) ||
                article.source.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Update filtered articles
        self.filteredArticles = filtered
    }
    
    func fetchNews() {
        isLoading = true
        errorMessage = nil
        NewsService.shared.fetchAllNews { [weak self] articles in
            DispatchQueue.main.async {
                self?.articles = articles
                self?.applyFilters(
                    region: self?.selectedRegion ?? "All",
                    category: self?.selectedCategory ?? "All",
                    searchText: self?.searchText ?? ""
                )
                self?.isLoading = false
                self?.isRefreshing = false
                
                if articles.isEmpty {
                    self?.errorMessage = "No news found. Please try again later."
                }
            }
        }
    }
    
    func refreshNews() {
        isRefreshing = true
        fetchNews()
    }
    
    func setRegion(_ region: String) {
        self.selectedRegion = region
    }
    
    func setCategory(_ category: String) {
        self.selectedCategory = category
    }
}