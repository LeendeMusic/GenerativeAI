import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    @State private var showModelSelection = false
    @State private var showModelManagement = false
    @State private var showSettings = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if viewModel.isProcessing {
                    ProgressView()
                        .padding()
                }
                
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.chatHistory) { message in
                                MessageView(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(.vertical)
                    }
                    .frame(maxHeight: geometry.size.height - 120)
                    .onChange(of: viewModel.chatHistory.count) { oldValue, newValue in
                        withAnimation {
                            proxy.scrollTo(viewModel.chatHistory.last?.id, anchor: .bottom)
                        }
                    }
                }
                
                Divider()
                
                HStack(spacing: 12) {
                    TextField("メッセージを入力", text: $viewModel.chatInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(viewModel.isProcessing)
                        .onSubmit {
                            Task {
                                await viewModel.sendMessage()
                            }
                        }
                    
                    Button(action: {
                        Task {
                            await viewModel.sendMessage()
                        }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(viewModel.isProcessing || viewModel.chatInput.isEmpty ? Color.gray : Color.blue)
                            )
                            .frame(width: 44, height: 44)
                    }
                    .disabled(viewModel.isProcessing || viewModel.chatInput.isEmpty)
                }
                .padding()
            }
        }
        .navigationTitle("チャット")
        .navigationBarItems(
    trailing: HStack {
    Button(action: {
        showModelManagement.toggle()
    }) {
        Image(systemName: "square.stack.3d.up")
    }
    
    Button(action: {
        viewModel.selectFolder()
    }) {
        Image(systemName: "folder.badge.plus")
    }
    
    Button(action: {
        showSettings.toggle()
    }) {
        Image(systemName: "gear")
    }
    
    Button(action: {
        viewModel.resetChat()
    }) {
        Image(systemName: "arrow.clockwise")
    }
}
)
.sheet(isPresented: $showModelManagement) {
    ModelManagementView(downloadManager: viewModel.modelDownloadManager)
}
.sheet(isPresented: $showSettings) {
    SettingsView()
}
    }
} 