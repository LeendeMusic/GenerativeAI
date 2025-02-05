@MainActor
class DummyMLManager: MLManager {
    override init() {
        super.init()
    }
    
    override func generateResponse(prompt: String) async throws -> String {
        return "申し訳ありませんが、現在CoreMLモデルが利用できないため、詳細な応答ができません。"
    }
    
    override func generateEmbedding(text: String) async throws -> [Float] {
        return Array(repeating: 0.0, count: 384)  // ダミーの埋め込みベクトル
    }
    
    override func generateResponseWithContext(prompt: String, context: [String]) async throws -> String {
        return "申し訳ありませんが、現在CoreMLモデルが利用できないため、文脈を考慮した応答ができません。"
    }
} 