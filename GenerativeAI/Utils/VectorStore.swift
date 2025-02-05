import Foundation

class VectorStore {
    private var documents: [(content: String, embedding: [Float])] = []
    
    func addDocument(content: String, embedding: [Float]) {
        documents.append((content, embedding))
    }
    
    func findSimilar(query: [Float], limit: Int = 3) -> [String] {
        let sorted = documents.sorted { doc1, doc2 in
            cosineSimilarity(query, doc1.embedding) > cosineSimilarity(query, doc2.embedding)
        }
        
        return Array(sorted.prefix(limit)).map { $0.content }
    }
    
    private func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        let dotProduct = zip(a, b).map(*).reduce(0, +)
        let normA = sqrt(a.map { $0 * $0 }.reduce(0, +))
        let normB = sqrt(b.map { $0 * $0 }.reduce(0, +))
        return dotProduct / (normA * normB)
    }
} 