import SwiftUI

struct MessageView: View {
    let message: ChatMessage
    
    var body: some View {
        VStack(alignment: message.isUser ? .trailing : .leading) {
            HStack {
                if message.isUser {
                    Spacer()
                }
                
                VStack(alignment: message.isUser ? .trailing : .leading) {
                    Text(message.content)
                        .padding()
                        .background(message.isUser ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                        .cornerRadius(12)
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = message.content
                            }) {
                                Text("コピー")
                                Image(systemName: "doc.on.doc")
                            }
                        }
                    
                    Text(formatDate(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 4)
                }
                
                if !message.isUser {
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .opacity
        ))
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
} 