import SwiftUI

struct ModelSelectionView: View {
    @Binding var selectedModel: ModelType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(ModelType.recommendedModels) { model in
                VStack(alignment: .leading) {
                    HStack {
                        Text(model.displayName)
                            .font(.headline)
                        Spacer()
                        if selectedModel.id == model.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    Text(model.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedModel = model
                    dismiss()
                }
            }
            .navigationTitle("モデルを選択")
            .navigationBarItems(trailing: Button("完了") { dismiss() })
        }
    }
} 