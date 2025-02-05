import Foundation

class HuggingFaceClient {
    private let baseURL = "https://huggingface.co/api"
    
    func searchModels(query: String) async throws -> [HuggingFaceModel] {
        var components = URLComponents(string: "\(baseURL)/models")!
        components.queryItems = [
            URLQueryItem(name: "search", value: query),
            URLQueryItem(name: "filter", value: "coreml"),
            URLQueryItem(name: "sort", value: "downloads"),
            URLQueryItem(name: "limit", value: "100")
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        if let token = SettingsManager.getHuggingFaceToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("Status code: \(httpResponse.statusCode)")
        print("Response headers: \(httpResponse.allHeaderFields)")
        print("Response data: \(String(data: data, encoding: .utf8) ?? "nil")")
        
        switch httpResponse.statusCode {
        case 200:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode([HuggingFaceModel].self, from: data)
        case 401:
            throw DownloadError.authenticationError
        default:
            throw URLError(.badServerResponse)
        }
    }
    
    func fetchCoreMLModels() async throws -> [HuggingFaceModel] {
        return try await searchModels(query: "coreml")
    }
}

struct HuggingFaceModel: Codable, Identifiable {
    let id: String
    let modelId: String
    let downloads: Int
    let tags: [String]
    let pipeline_tag: String?
    let license: String?
    
    var name: String {
        return modelId.components(separatedBy: "/").last ?? modelId
    }
    
    var isCoreMLCompatible: Bool {
        return tags.contains { tag in
            tag.lowercased().contains("coreml") ||
            tag.lowercased().contains("mlc-llm")
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case modelId = "id"
        case downloads
        case tags
        case pipeline_tag
        case license
    }
} 