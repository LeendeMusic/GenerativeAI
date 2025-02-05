import CoreML
import NaturalLanguage

@MainActor
class MLManager {
    private let model: MLModel
    private let tokenizer: NLTokenizer
    private let modelType: ModelType
    
    init(modelType: ModelType) async throws {
        self.modelType = modelType
        self.tokenizer = NLTokenizer(unit: .word)
        
        let fileManager = FileManager.default
        let modelDirectory = try ModelDownloadManager().getModelDirectory()
        let modelPath = modelDirectory.appendingPathComponent("\(modelType.modelFileName).mlmodelc")
        
        if !fileManager.fileExists(atPath: modelPath.path) {
            throw MLError.modelNotFound(modelType)
        }
        
        guard let loadedModel = try? MLModel(contentsOf: modelPath) else {
            throw MLError.modelNotFound(modelType)
        }
        self.model = loadedModel
    }
    
    init() {
        self.modelType = .huggingface(
            repo: "default-model",
            name: "Default Model",
            description: "デフォルトモデル"
        )
        self.tokenizer = NLTokenizer(unit: .word)
        self.model = MLModel()  // ダミーのモデル
    }
    
    func generateEmbedding(text: String) async throws -> [Float] {
        let featureValue = MLFeatureValue(string: text)
        let featureProvider = try MLDictionaryFeatureProvider(dictionary: ["text": featureValue])
        
        guard let output = try? await model.prediction(from: featureProvider),
              let embedding = output.featureValue(for: "embedding")?.multiArrayValue else {
            throw MLError.embeddingFailed
        }
        
        return (0..<embedding.count).map { Float(embedding[$0].doubleValue) }
    }
    
    func generateResponse(prompt: String) async throws -> String {
        let featureValue = MLFeatureValue(string: prompt)
        let featureProvider = try MLDictionaryFeatureProvider(dictionary: ["prompt": featureValue])
        
        guard let output = try? await model.prediction(from: featureProvider),
              let response = output.featureValue(for: "response")?.stringValue else {
            throw MLError.inferenceError
        }
        return response
    }
    
    func generateResponseWithContext(prompt: String, context: [String]) async throws -> String {
        let enhancedPrompt = """
        文脈:
        \(context.joined(separator: "\n\n"))
        
        質問: \(prompt)
        """
        return try await generateResponse(prompt: enhancedPrompt)
    }
}

enum MLError: LocalizedError {
    case modelNotFound(ModelType)
    case embeddingFailed
    case inferenceError
    
    var errorDescription: String? {
        switch self {
        case .modelNotFound(let modelType):
            return """
            CoreMLモデルファイルが見つかりません。
            モデル: \(modelType.displayName)
            ファイル名: \(modelType.modelFileName).mlmodelc
            
            以下を確認してください：
            1. モデルがダウンロードされているか
            2. モデルファイルが正しく変換されているか
            3. アプリに必要な権限があるか
            """
        case .embeddingFailed:
            return "テキストの埋め込み生成に失敗しました"
        case .inferenceError:
            return "応答の生成に失敗しました"
        }
    }
} 