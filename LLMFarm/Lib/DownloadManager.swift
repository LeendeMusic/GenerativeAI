//
//  DownloadManager.swift
//  LocalMind
//
//  Created by guinmoon on 08.09.2023.
//

import Foundation


final class DownloadManager: NSObject, ObservableObject, URLSessionDownloadDelegate {
    static let shared = DownloadManager()
    
    @Published var isDownloading = false
    @Published var isDownloaded = false
    @Published var progress: Double = 0.0
    @Published var currentFileName: String = ""
    @Published var downloadStatus: String = "download"
    
    @Published var bytesWritten: Int64 = 0
    @Published var totalBytes: Int64 = 0
    @Published var downloadSpeed: Double = 0
    @Published var estimatedTimeRemaining: TimeInterval = 0
    
    private var lastBytesWritten: Int64 = 0
    private var lastSpeedUpdateTime = Date()
    
    private override init() {
        super.init()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let response = downloadTask.response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
            print("Server error!")
            DispatchQueue.main.async {
                self.isDownloading = false
                self.isDownloaded = false
                self.downloadStatus = "error"
            }
            return
        }
        
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsPath.appendingPathComponent("models").appendingPathComponent(currentFileName)
            
            try FileManager.default.createDirectory(at: documentsPath.appendingPathComponent("models"), withIntermediateDirectories: true)
            try FileManager.default.copyItem(at: location, to: destinationURL)
            
            DispatchQueue.main.async {
                self.isDownloading = false
                self.isDownloaded = true
                self.downloadStatus = "downloaded"
            }
        } catch {
            print("Error saving file: \(error)")
            DispatchQueue.main.async {
                self.downloadStatus = "error"
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let now = Date()
        let timeInterval = now.timeIntervalSince(self.lastSpeedUpdateTime)
        
        DispatchQueue.main.async {
            self.totalBytes = totalBytesExpectedToWrite
            self.bytesWritten = totalBytesWritten
            
            if timeInterval >= 1.0 {
                let bytesPerSecond = Double(totalBytesWritten - self.lastBytesWritten) / timeInterval
                let remainingBytes = Double(totalBytesExpectedToWrite - totalBytesWritten)
                
                self.downloadSpeed = bytesPerSecond
                self.estimatedTimeRemaining = remainingBytes / bytesPerSecond
                
                self.lastBytesWritten = totalBytesWritten
                self.lastSpeedUpdateTime = now
            }
            
            self.progress = totalBytesExpectedToWrite > 0 ? Double(totalBytesWritten) / Double(totalBytesExpectedToWrite) : 0.0
        }
    }
    
    func downloadFile() {
        print("downloadFile")
        isDownloading = true
        
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        let destinationUrl = docsUrl?.appendingPathComponent("myVideo.mp4")
        if let destinationUrl = destinationUrl {
            if (FileManager().fileExists(atPath: destinationUrl.path)) {
                print("File already exists")
                isDownloading = false
            } else {
                let urlRequest = URLRequest(url: URL(string: "https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_480_1_5MG.mp4")!)
                
                let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                    
                    if let error = error {
                        print("Request error: ", error)
                        self.isDownloading = false
                        return
                    }
                    
                    guard let response = response as? HTTPURLResponse else { return }
                    
                    if response.statusCode == 200 {
                        guard let data = data else {
                            self.isDownloading = false
                            return
                        }
                        DispatchQueue.main.async {
                            do {
                                try data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                                
                                DispatchQueue.main.async {
                                    self.isDownloading = false
                                    self.isDownloaded = true
                                }
                            } catch let error {
                                print("Error decoding: ", error)
                                self.isDownloading = false
                            }
                        }
                    }
                }
                dataTask.resume()
            }
        }
    }
    
    func deleteFile() {
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        let destinationUrl = docsUrl?.appendingPathComponent("myVideo.mp4")
        if let destinationUrl = destinationUrl {
            guard FileManager().fileExists(atPath: destinationUrl.path) else { return }
            do {
                try FileManager().removeItem(atPath: destinationUrl.path)
                print("File deleted successfully")
                isDownloaded = false
            } catch let error {
                print("Error while deleting video file: ", error)
            }
        }
    }
    
    func checkFileExists() {
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        let destinationUrl = docsUrl?.appendingPathComponent("myVideo.mp4")
        if let destinationUrl = destinationUrl {
            if (FileManager().fileExists(atPath: destinationUrl.path)) {
                isDownloaded = true
            } else {
                isDownloaded = false
            }
        } else {
            isDownloaded = false
        }
    }
    
//    func getVideoFileAsset() -> AVPlayerItem? {
//        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
//        
//        let destinationUrl = docsUrl?.appendingPathComponent("myVideo.mp4")
//        if let destinationUrl = destinationUrl {
//            if (FileManager().fileExists(atPath: destinationUrl.path)) {
//                let avAssest = AVAsset(url: destinationUrl)
//                return AVPlayerItem(asset: avAssest)
//            } else {
//                return nil
//            }
//        } else {
//            return nil
//        }
//    }
    
    func startDownload(url: URL) {
        isDownloading = true
        isDownloaded = false
        downloadStatus = "downloading"
        progress = 0.0
        bytesWritten = 0
        totalBytes = 0
        downloadSpeed = 0
        estimatedTimeRemaining = 0
        lastBytesWritten = 0
        lastSpeedUpdateTime = Date()
        
        let config = URLSessionConfiguration.background(withIdentifier: "com.LocalMind.modeldownload")
        config.sessionSendsLaunchEvents = true
        config.isDiscretionary = false
        
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        let downloadTask = session.downloadTask(with: url)
        downloadTask.resume()
    }
}
