import Foundation

enum ModelType: Identifiable, Hashable {
    case huggingface(repo: String, name: String, description: String)
    
    var id: String {
        switch self {
        case .huggingface(let repo, _, _):
            return repo
        }
    }
    
    var displayName: String {
        switch self {
        case .huggingface(_, let name, _):
            return name
        }
    }
    
    var description: String {
        switch self {
        case .huggingface(_, _, let description):
            return description
        }
    }
    
    var modelFileName: String {
        switch self {
        case .huggingface(let repo, _, _):
            return repo.replacingOccurrences(of: "/", with: "_")
        }
    }
    
    static var recommendedModels: [ModelType] = [
        .huggingface(
            repo: "mlc-ai/mlc-chat-Llama-2-7b-chat-q4f32_1",
            name: "Llama 2 7B",
            description: "Meta社の高性能な会話モデル（商用利用可能）"
        ),
        .huggingface(
            repo: "mlc-ai/mlc-chat-Mistral-7B-Instruct-v0.2-q4f32_1",
            name: "Mistral 7B",
            description: "高性能な指示対応モデル（商用利用可能）"
        ),
        .huggingface(
            repo: "mlc-ai/mlc-chat-RedPajama-INCITE-Chat-3B-v1-q4f32_1",
            name: "RedPajama 3B",
            description: "軽量な会話モデル（Apache 2.0ライセンス）"
        )
    ]
} 