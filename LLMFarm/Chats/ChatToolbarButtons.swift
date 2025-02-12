struct ChatToolbarButtons: View {
    @EnvironmentObject var aiChatModel: AIChatModel
    @Binding var clearChatAlert: Bool
    @Binding var clearChatButtonIcon: String
    @Binding var reloadButtonIcon: String
    @Binding var toggleEditChat: Bool
    @Binding var editChatDialog: Bool
    
    var hard_reload_chat: () -> Void
    var run_after_delay: (Int, @escaping () -> Void) -> Void
    
    var body: some View {
        HStack {
            Button {
                Task {
                    clearChatAlert = true
                }
            } label: {
                Image(systemName: clearChatButtonIcon)
            }
            .alert("Are you sure?", isPresented: $clearChatAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    aiChatModel.messages = []
                    save_chat_history(aiChatModel.messages,aiChatModel.chat_name+".json")
                    clearChatButtonIcon = "checkmark"
                    hard_reload_chat()
                    run_after_delay(1200, {clearChatButtonIcon = "eraser.line.dashed.fill"})
                }
            } message: {
                Text("The message history will be cleared")
            }
            
            Button {
                Task {
                    hard_reload_chat()
                    reloadButtonIcon = "checkmark"
                    run_after_delay(1200, {reloadButtonIcon = "arrow.counterclockwise.circle"})
                }
            } label: {
                Image(systemName: reloadButtonIcon)
            }
            .disabled(aiChatModel.predicting)
            
            Button {
                Task {
                    toggleEditChat = true
                    editChatDialog = true
                }
            } label: {
                Image(systemName: "slider.horizontal.3")
            }
        }
    }
} 
