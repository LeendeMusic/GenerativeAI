import SwiftUI

struct ModelListView: View {
    @ObservedObject var downloadManager: ModelDownloadManager
    @State private var models: [HuggingFaceModel] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var filterText = ""
    
    private let client = HuggingFaceClient()
    
    var filteredModels: [HuggingFaceModel] {
        if filterText.isEmpty {
            return models
        }
        return models.filter { model in
            model.name.localizedCaseInsensitiveContains(filterText) ||
            model.modelId.localizedCaseInsensitiveContains(filterText)
        }
    }
    
    var body: some View {
        VStack {
            TextField("フィルター", text: $filterText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if isLoading {
                ProgressView()
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else {
                List(filteredModels) { model in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(model.name)
                                .font(.headline)
                            Spacer()
                            Text("⬇️ \(model.downloads)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Text(model.modelId)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            let modelType = ModelType.huggingface(
                                repo: model.modelId,
                                name: model.name,
                                description: "ダウンロード数: \(model.downloads)"
                            )
                            Task {
                                try await downloadManager.downloadAndConvertModel(modelType)
                            }
                        }) {
                            Text("インストール")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("CoreMLモデル")
        .task {
            await loadModels()
        }
    }
    
    private func loadModels() async {
        isLoading = true
        errorMessage = nil
        
        do {
            models = try await client.fetchCoreMLModels()
            isLoading = false
        } catch {
            errorMessage = "モデルの取得に失敗しました: \(error.localizedDescription)"
            isLoading = false
        }
    }
} 