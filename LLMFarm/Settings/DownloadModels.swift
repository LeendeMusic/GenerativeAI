//
//  ContactsView.swift
//  ChatUI
//
//  Created by Shezad Ahamed on 05/08/21.
//

import SwiftUI
import UniformTypeIdentifiers

public protocol Tabbable: Identifiable {
    associatedtype Id
    var id: Id { get }
    
    var name : String { get }
}

struct DownloadModelsView: View {
    @StateObject private var downloadManager = DownloadManager.shared
    @State private var customUrl: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @Environment(\.scenePhase) private var scenePhase
    
    var downloadStatusBar: some View {
        Group {
            if downloadManager.downloadStatus == "downloading" {
                VStack {
                    HStack {
                        Image(systemName: "arrow.down.circle")
                        Text("\(downloadManager.currentFileName)")
                        Spacer()
                        Button(action: {
                            downloadManager.downloadStatus = "download"
                        }) {
                            Image(systemName: "stop.circle.fill")
                        }
                    }
                    
                    HStack {
                        Text(String(format: "%.1f/%.1f GB", 
                             Double(downloadManager.bytesWritten) / 1_000_000_000,
                             Double(downloadManager.totalBytes) / 1_000_000_000))
                        Spacer()
                        Text(String(format: "%.1f MB/s", 
                             downloadManager.downloadSpeed / 1_000_000))
                        Spacer()
                        Text(String(format: "残り %.0f分", 
                             downloadManager.estimatedTimeRemaining / 60))
                    }
                    .font(.caption)
                    
                    ProgressView(value: downloadManager.progress)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
            }
        }
    }
    
    private func startDownload() {
        if !customUrl.isEmpty {
            let fileName = URL(string: customUrl)?.lastPathComponent ?? "model.gguf"
            downloadManager.currentFileName = fileName
            
            guard let url = URL(string: customUrl) else { return }
            downloadManager.startDownload(url: url)
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                TextField("Hugging Face GGUFのURLを入力", text: $customUrl)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(downloadManager.downloadStatus == "downloading")
                
                if downloadManager.downloadStatus == "downloading" {
                    Button(action: {
                        downloadManager.downloadStatus = "download"
                    }) {
                        Image(systemName: "stop.circle.fill")
                    }
                } else {
                    Button(action: startDownload) {
                        Image(systemName: "icloud.and.arrow.down")
                    }
                    .disabled(customUrl.isEmpty)
                }
            }
            .padding()
            
            downloadStatusBar
            
            Spacer()
        }
        .navigationTitle("Download models")
        .alert("ダウンロードエラー", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onChange(of: downloadManager.downloadStatus) { newStatus in
            if newStatus == "downloaded" {
                customUrl = ""
            } else if newStatus == "error" {
                showError = true
                errorMessage = "ダウンロード中にエラーが発生しました"
            }
        }
    }
}

