import Foundation

class DocumentManager {
    private let mlManager: MLManager
    
    init(mlManager: MLManager) {
        self.mlManager = mlManager
    }
    
    func readDocuments(at url: URL) throws -> [(String, URL)] {
        let fileManager = FileManager.default
        var documents: [(String, URL)] = []
        
        if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]) {
            for case let fileURL as URL in enumerator {
                if let content = try? String(contentsOf: fileURL, encoding: .utf8) {
                    documents.append((content, fileURL))
                }
            }
        }
        
        return documents
    }
    
    func createEmbeddings(for documents: [(String, URL)]) async throws -> [(content: String, embedding: [Float], url: URL)] {
        var result: [(content: String, embedding: [Float], url: URL)] = []
        
        for (content, url) in documents {
            let embedding = try await mlManager.generateEmbedding(text: content)
            result.append((content: content, embedding: embedding, url: url))
        }
        
        return result
    }
} 