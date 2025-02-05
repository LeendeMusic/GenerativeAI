import SwiftUI
import UniformTypeIdentifiers

struct FolderSelectionView: View {
    @ObservedObject var viewModel: ChatViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding(.bottom)
            
            Text("ドキュメントフォルダを選択してください")
                .font(.headline)
                .padding(.bottom, 8)
            
            Text("選択したフォルダ内のドキュメントを分析し、チャットの文脈として使用します")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.bottom)
            
            if let folder = viewModel.selectedFolder {
                Text(folder.path)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
            
            if viewModel.isProcessing {
                ProgressView()
                    .padding()
            }
            
            Button(action: {
                viewModel.selectFolder()
            }) {
                HStack {
                    Image(systemName: "folder")
                    Text("フォルダを選択")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
            .disabled(viewModel.isProcessing)
        }
        .padding()
        .onDrop(of: [.folder], isTargeted: nil) { providers in
            guard let provider = providers.first else { return false }
            
            provider.loadItem(forTypeIdentifier: UTType.folder.identifier, options: nil) { (urlData, error) in
                if let urlData = urlData as? Data,
                   let url = URL(dataRepresentation: urlData, relativeTo: nil) {
                    Task {
                        await viewModel.processSelectedFolder(url)
                    }
                }
            }
            return true
        }
    }
} 