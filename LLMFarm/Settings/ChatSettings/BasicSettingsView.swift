import SwiftUI

struct BasicSettingsView: View {
    @Binding var chat_title: String
    @Binding var model_icon: String
    @Binding var model_icons: [String]
    @Binding var model_inferences: [String]
    @Binding var ggjt_v3_inferences: [String]
    @Binding var model_inference: String
    @Binding var ggjt_v3_inference: String
    @State private var showEmojiPicker = false
    @State private var showInvalidInputAlert = false
    
    // 絵文字かどうかをチェックする関数
    private func isEmoji(_ text: String) -> Bool {
        for scalar in text.unicodeScalars {
            switch scalar.properties.generalCategory {
            case .otherSymbol, .privateUse:
                return true
            default:
                continue
            }
        }
        return false
    }
    
    var body: some View {
        HStack {
            Button(action: {
                showEmojiPicker.toggle()
            }) {
                Text(model_icon)
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Circle())
            }
            .sheet(isPresented: $showEmojiPicker) {
                EmojiPickerView(selectedEmoji: $model_icon)
                    .presentationDetents([.medium])
            }
            
            #if os(macOS)
            DidEndEditingTextField(text: $chat_title, didEndEditing: { newName in })
                .frame(maxWidth: .infinity, alignment: .leading)
            #else
            TextField("Chat Title", text: $chat_title)
                .frame(maxWidth: .infinity, alignment: .leading)
            #endif
        }
        .padding(.horizontal)
        .overlay(
            showInvalidInputAlert ?
            Text("絵文字のみ使用可能です")
                .font(.caption)
                .foregroundColor(.red)
                .offset(y: 30)
            : nil
        )
    }
}

struct EmojiPickerView: View {
    @Binding var selectedEmoji: String
    @Environment(\.dismiss) var dismiss
    
    let emojis = ["😀","😊","🤖","💡","🎯","📚","💭","🗣️","🤔","🌟",
                  "🎨","🔮","🎲","🎮","📱","💻","🌍","🚀","⭐️","💪",
                  "🧠","📝","💬","❓","❗️","✨","🎵","🎬","📸","🎪"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
                    ForEach(emojis, id: \.self) { emoji in
                        Button(action: {
                            selectedEmoji = emoji
                            dismiss()
                        }) {
                            Text(emoji)
                                .font(.system(size: 30))
                                .padding(5)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("絵文字を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
}
