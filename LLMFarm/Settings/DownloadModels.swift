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
        VStack(spacing: 12) {
            if downloadManager.downloadStatus == "downloading" {
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(.title3)
                        Text(downloadManager.currentFileName)
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            downloadManager.downloadStatus = "download"
                        }) {
                            Image(systemName: "stop.circle.fill")
                                .foregroundColor(.red)
                                .font(.title3)
                        }
                    }
                    
                    ProgressView(value: downloadManager.progress)
                        .tint(.accentColor)
                    
                    HStack(spacing: 12) {
                        Label(
                            String(format: "%.1f/%.1f GB",
                                  Double(downloadManager.bytesWritten) / 1_000_000_000,
                                  Double(downloadManager.totalBytes) / 1_000_000_000),
                            systemImage: "doc.fill"
                        )
                        Spacer()
                        Label(
                            String(format: "%.1f MB/s",
                                  downloadManager.downloadSpeed / 1_000_000),
                            systemImage: "speedometer"
                        )
                        Spacer()
                        Label(
                            String(format: "残り%.0f分",
                                  downloadManager.estimatedTimeRemaining / 60),
                            systemImage: "timer"
                        )
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5)
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

