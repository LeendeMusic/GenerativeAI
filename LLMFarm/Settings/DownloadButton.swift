import SwiftUI

struct DownloadButton: View {
    
    @Binding var modelName: String
    @Binding var modelUrl: String
    @Binding var filename: String
    
    @Binding var status: String
    
    @State private var downloadTask: URLSessionDownloadTask?
    @State private var progress = 0.0
    @State private var observation: NSKeyValueObservation?
    

    
    private func checkFileExistenceAndUpdateStatus() {
    }
    

    
    func download() {
        status = "downloading"
        print("Downloading model \(modelName) from \(modelUrl)")
        guard let url = URL(string: modelUrl) else { return }
        let fileURL = getFileURLFormPathStr(dir:"models", filename: filename)
        
        downloadTask = URLSession.shared.downloadTask(with: url) { temporaryURL, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    status = "error"
                }
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                print("Server error!")
                DispatchQueue.main.async {
                    status = "error"
                }
                return
            }
            
            do {
                if let temporaryURL = temporaryURL {
                    try FileManager.default.copyItem(at: temporaryURL, to: fileURL)
                    print("Writing to \(filename) completed")
                    DispatchQueue.main.async {
                        status = "downloaded"
                    }
                }
            } catch {
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    status = "error"
                }
            }
        }
        
        observation = downloadTask?.progress.observe(\.fractionCompleted) { observationProgress, _ in
            progress = observationProgress.fractionCompleted
        }
        
        downloadTask?.resume()
    }
    
    var body: some View {
        VStack {
            switch status {
            case "download":
                    Button(action: download) {
                        Image(systemName:"icloud.and.arrow.down")
                    }
                    .buttonStyle(.borderless)
            case "downloading":
                    Button(action: {
                        downloadTask?.cancel()
                        status = "download"
                    }) {
                        HStack{
                            Image(systemName:"stop.circle.fill")
                            Text("\(Int(progress * 100))%")
                                .padding(.trailing,-20)
                        }
                    }
                    .buttonStyle(.borderless)
            case "downloaded":
                    Image(systemName:"checkmark.circle.fill")
            default:
                    Text("Unknown status")
            }
        }
        .onDisappear() {
            downloadTask?.cancel()
        }.onChange(of: status) { st in
            print(st)
        }
        // .onChange(of: llamaState.cacheCleared) { newValue in
        //     if newValue {
        //         downloadTask?.cancel()
        //         let fileURL = DownloadButton.getFileURL(filename: filename)
        //         status = FileManager.default.fileExists(atPath: fileURL.path) ? "downloaded" : "download"
        //     }
        // }
    }
}

enum DownloadError: Error {
    case invalidURL
    case serverError
}

