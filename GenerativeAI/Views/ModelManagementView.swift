import SwiftUI

struct ModelManagementView: View {
    @ObservedObject var downloadManager: ModelDownloadManager
    @Environment(\.dismiss) private var dismiss
    @State private var showModelSearch = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("おすすめモデル")) {
                    ForEach(ModelType.recommendedModels) { model in
                        ModelListItem(model: model, downloadManager: downloadManager)
                    }
                }
                
                Section {
                    Button(action: {
                        showModelSearch = true
                    }) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("他のモデルを検索")
                        }
                    }
                }
            }
            .navigationTitle("モデル管理")
            .navigationBarItems(trailing: Button("完了") { dismiss() })
            .sheet(isPresented: $showModelSearch) {
                NavigationView {
                    ModelListView(downloadManager: downloadManager)
                }
            }
        }
    }
}

struct ModelStatusView: View {
    let model: ModelType
    @ObservedObject var downloadManager: ModelDownloadManager
    
    var body: some View {
        Group {
            if downloadManager.isModelInstalled(model) {
                HStack {
                    Text("インストール済")
                        .font(.caption)
                        .foregroundColor(.green)
                    Button(action: {
                        Task {
                            try await downloadManager.deleteModel(model)
                        }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            } else if downloadManager.isDownloading && downloadManager.currentDownloadModel == model {
                HStack {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text("\(Int(downloadManager.downloadProgress * 100))%")
                        .font(.caption)
                }
            } else {
                Button(action: {
                    Task {
                        do {
                            try await downloadManager.downloadAndConvertModel(model)
                        } catch {
                            print("モデルのダウンロードまたは変換に失敗: \(error.localizedDescription)")
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "icloud.and.arrow.down")
                        Text("インストール")
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

struct ModelListItem: View {
    let model: ModelType
    @ObservedObject var downloadManager: ModelDownloadManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(model.displayName)
                    .font(.headline)
                Text(model.description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            ModelStatusView(model: model, downloadManager: downloadManager)
        }
        .padding(.vertical, 4)
    }
} 