import Foundation

@MainActor
class ModelDownloadManager: ObservableObject {
    @Published var downloadProgress: Double = 0
    @Published var isDownloading = false
    @Published var currentDownloadModel: ModelType?
    
    private var huggingFaceToken: String? {
    return SettingsManager.getHuggingFaceToken()
}
    
    private func getHuggingFaceModelURL(_ modelType: ModelType) -> URL? {
        switch modelType {
        case .huggingface(let repo, _, _):
            let baseURL = "https://huggingface.co"
            let modelPath = "\(baseURL)/\(repo)/resolve/main"
            return URL(string: "\(modelPath)/model.mlpackage")
        }
    }
    
    func downloadAndConvertModel(_ modelType: ModelType) async throws {
        let modelDirectory = try getModelDirectory()
        let modelPath = modelDirectory.appendingPathComponent("\(modelType.modelFileName).mlmodelc")
        
        currentDownloadModel = modelType
        isDownloading = true
        
        do {
            let downloadURL = try await downloadMLModel(modelType)
            try await unzipAndInstallModel(from: downloadURL, to: modelPath)
        } catch {
            isDownloading = false
            currentDownloadModel = nil
            throw error
        }
        
        isDownloading = false
        currentDownloadModel = nil
    }
    
    private func downloadMLModel(_ modelType: ModelType) async throws -> URL {
        guard let token = huggingFaceToken else {
            throw DownloadError.authenticationError
        }
        
        guard let modelURL = getHuggingFaceModelURL(modelType) else {
            throw DownloadError.invalidURL
        }
        
        var request = URLRequest(url: modelURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 300
        
        let session = URLSession.shared
        let (downloadURL, response) = try await session.download(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DownloadError.serverError
        }
        
        switch httpResponse.statusCode {
        case 200:
            return downloadURL
        case 401, 403:
            SettingsManager.removeHuggingFaceToken()
            throw DownloadError.authenticationError
        default:
            print("サーバーエラー: ステータスコード \(httpResponse.statusCode)")
            throw DownloadError.serverError
        }
    }
    
    private func unzipAndInstallModel(from zipURL: URL, to destination: URL) async throws {
        // ZIPファイルの解凍とインストール処理
        // 必要に応じてここでCoreMLへの変換処理も行う
    }
    
    func getModelDirectory() throws -> URL {
        let fileManager = FileManager.default
        let appSupport = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let modelDirectory = appSupport.appendingPathComponent("Models", isDirectory: true)
        
        if !fileManager.fileExists(atPath: modelDirectory.path) {
            try fileManager.createDirectory(at: modelDirectory, withIntermediateDirectories: true)
        }
        
        return modelDirectory
    }
    
    func isModelInstalled(_ modelType: ModelType) -> Bool {
        let modelDirectory = try? getModelDirectory()
        let modelPath = modelDirectory?.appendingPathComponent("\(modelType.modelFileName).mlmodelc")
        return modelPath.map { FileManager.default.fileExists(atPath: $0.path) } ?? false
    }
    
    func deleteModel(_ modelType: ModelType) async throws {
        let modelDirectory = try getModelDirectory()
        let modelPath = modelDirectory.appendingPathComponent("\(modelType.modelFileName).mlmodelc")
        if FileManager.default.fileExists(atPath: modelPath.path) {
            try FileManager.default.removeItem(at: modelPath)
        }
    }
}

enum DownloadError: LocalizedError {
    case invalidURL
    case serverError
    case authenticationError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "モデルのダウンロードURLが無効です"
        case .serverError:
            return "サーバーからのダウンロードに失敗しました"
        case .authenticationError:
            return "HuggingFaceの認証に失敗しました"
        }
    }
}

enum ConversionError: LocalizedError {
    case conversionFailed
    
    var errorDescription: String? {
        switch self {
        case .conversionFailed:
            return "モデルのCoreML形式への変換に失敗しました"
        }
    }
} 