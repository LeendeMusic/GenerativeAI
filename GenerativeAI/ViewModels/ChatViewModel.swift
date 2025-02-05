import SwiftUI
import UniformTypeIdentifiers

@MainActor
final class ChatViewModel: NSObject, ObservableObject {
    @Published var selectedFolder: URL?
    @Published var chatInput: String = ""
    @Published var chatHistory: [ChatMessage] = []
    @Published var isProcessing = false
    @Published var selectedModelType: ModelType = .huggingface(
        repo: "mlc-ai/mlc-chat-RedPajama-INCITE-Chat-3B-v1-q4f32_1",
        name: "RedPajama 3B",
        description: "軽量な会話モデル（小規模）"
    ) {
        didSet {
            Task {
                await initializeModel()
            }
        }
    }
    
    private var mlManager: MLManager
    private var documentManager: DocumentManager
    var modelDownloadManager = ModelDownloadManager()
    private var processedDocuments: [(content: String, embedding: [Float], url: URL)] = []
    
    override init() {
        self.mlManager = DummyMLManager()
        self.documentManager = DocumentManager(mlManager: mlManager)
        super.init()
        
        Task {
            await initializeModel()
        }
    }
    
    private func initializeModel() async {
        isProcessing = true
        do {
            mlManager = try await MLManager(modelType: selectedModelType)
            documentManager = DocumentManager(mlManager: mlManager)
            processedDocuments.removeAll()
        } catch {
            let errorMessage = ChatMessage(
                content: "モデルの初期化に失敗しました: \(error.localizedDescription)",
                isUser: false
            )
            chatHistory.append(errorMessage)
        }
        isProcessing = false
    }
    
    func selectFolder() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder], asCopy: false)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(documentPicker, animated: true)
        }
    }
    
    func processSelectedFolder(_ url: URL) async {
        isProcessing = true
        selectedFolder = url
        
        do {
            let documents = try documentManager.readDocuments(at: url)
            processedDocuments = try await documentManager.createEmbeddings(for: documents)
            
            let welcomeMessage = ChatMessage(
                content: "フォルダの処理が完了しました。質問してください。",
                isUser: false
            )
            chatHistory.append(welcomeMessage)
        } catch {
            let errorMessage = ChatMessage(
                content: "エラーが発生しました: \(error.localizedDescription)",
                isUser: false
            )
            chatHistory.append(errorMessage)
        }
        
        isProcessing = false
    }
    
    func sendMessage() async {
        guard !chatInput.isEmpty else { return }
        isProcessing = true
        
        let messageText = chatInput  // 現在の入力内容を保存
        chatInput = ""  // 入力欄をクリア
        
        let userMessage = ChatMessage(content: messageText, isUser: true)
        chatHistory.append(userMessage)
        
        let aiMessage = ChatMessage(content: "", isUser: false)
        chatHistory.append(aiMessage)
        
        do {
            let response: String
            if processedDocuments.isEmpty {
                response = try await mlManager.generateResponse(prompt: messageText)
            } else {
                let queryEmbedding = try await mlManager.generateEmbedding(text: messageText)
                let relevantDocs = processedDocuments
                    .sorted { doc1, doc2 in
                        cosineSimilarity(queryEmbedding, doc1.embedding) >
                        cosineSimilarity(queryEmbedding, doc2.embedding)
                    }
                    .prefix(3)
                    .map { $0.content }
                
                response = try await mlManager.generateResponseWithContext(
                    prompt: messageText,
                    context: relevantDocs
                )
            }
            
            chatHistory[chatHistory.count - 1] = ChatMessage(
                content: response,
                isUser: false
            )
        } catch {
            chatHistory[chatHistory.count - 1] = ChatMessage(
                content: "エラーが発生しました: \(error.localizedDescription)",
                isUser: false
            )
        }
        
        isProcessing = false
    }
    
    func resetChat() {
        selectedFolder = nil
        chatHistory.removeAll()
        chatInput = ""
        processedDocuments.removeAll()
    }
    
    private func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        let dotProduct = zip(a, b).map(*).reduce(0, +)
        let normA = sqrt(a.map { $0 * $0 }.reduce(0, +))
        let normB = sqrt(b.map { $0 * $0 }.reduce(0, +))
        return dotProduct / (normA * normB)
    }
}

extension ChatViewModel: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        Task {
            await processSelectedFolder(url)
        }
    }
} 