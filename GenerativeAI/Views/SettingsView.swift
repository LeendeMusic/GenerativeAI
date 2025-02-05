import SwiftUI

struct SettingsView: View {
    @State private var huggingFaceToken: String = SettingsManager.getHuggingFaceToken() ?? ""
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("HuggingFace設定")) {
                    SecureField("APIトークン", text: $huggingFaceToken)
                    
                    Button(action: {
                        if !huggingFaceToken.isEmpty {
                            SettingsManager.saveHuggingFaceToken(huggingFaceToken)
                            showAlert = true
                        }
                    }) {
                        Text("保存")
                    }
                    .disabled(huggingFaceToken.isEmpty)
                }
                
                Section(header: Text("情報")) {
                    Text("HuggingFaceのAPIトークンを入力することで、モデルをダウンロードできるようになります。一度ダウンロードしたモデルは、オフラインでも使用できます。")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("設定")
            .navigationBarItems(trailing: Button("完了") { dismiss() })
            .alert("保存完了", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("APIトークンを保存しました")
            }
        }
    }
} 