import SwiftUI

struct ModelSearchView: View {
    @State private var searchText = ""
    @State private var models: [HuggingFaceModel] = []
    @State private var isSearching = false
    @State private var errorMessage: String?
    
    private let client = HuggingFaceClient()
    @ObservedObject var downloadManager: ModelDownloadManager
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText, onSubmit: performSearch)
                .padding()
            
            if isSearching {
                ProgressView()
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else {
                List(models) { model in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(model.name)
                                .font(.headline)
                            Spacer()
                            if model.isCoreMLCompatible {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        
                        Text("ダウンロード数: \(model.downloads)")
                            .font(.caption)
                        Text("ライセンス: \(model.license ?? "不明")")
                            .font(.caption)
                        
                        if model.isCoreMLCompatible {
                            Button(action: {
                                let modelType = ModelType.huggingface(
                                    repo: model.modelId,
                                    name: model.name,
                                    description: "HuggingFaceからインポートされたモデル"
                                )
                                Task {
                                    try await downloadManager.downloadAndConvertModel(modelType)
                                }
                            }) {
                                Text("インストール")
                                    .foregroundColor(.blue)
                            }
                        } else {
                            Text("CoreML非対応")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("モデルを検索")
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        errorMessage = nil
        
        Task {
            do {
                models = try await client.searchModels(query: searchText)
                    .filter { $0.isCoreMLCompatible }
                isSearching = false
            } catch {
                errorMessage = "検索中にエラーが発生しました: \(error.localizedDescription)"
                isSearching = false
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    let onSubmit: () -> Void
    
    var body: some View {
        HStack {
            TextField("モデル名を入力", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit(onSubmit)
            
            Button(action: onSubmit) {
                Image(systemName: "magnifyingglass")
            }
        }
    }
} 