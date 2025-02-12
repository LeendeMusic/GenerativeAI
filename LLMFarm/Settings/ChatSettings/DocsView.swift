//
//  DocsView.swift
//  LLMFarm
//
//  Created by guinmoon on 19.10.2024.
//

import SwiftUI

//
//  ContactsView.swift
//  ChatUI
//
//  Created by Shezad Ahamed on 05/08/21.
//

import SwiftUI
import UniformTypeIdentifiers
import SimilaritySearchKit
import SimilaritySearchKitDistilbert
import SimilaritySearchKitMiniLMAll
import SimilaritySearchKitMiniLMMultiQA




struct indexUpdatePopoverContent: View {
    @Binding var importStatus: String
    @State private var animationsRunning = false
    var body: some View {
        VStack{
            Text(importStatus).padding()
            ThreeDots()
        }
    }
//    .frame(minWidth: 300,minHeight: 200, maxHeight: 200)
}

struct DocsView: View {
    
    public var dir:String
    @State var searchText: String = ""
    @State var docsPreviews: [Dictionary<String, String>]
    @State var docSelection: String?
    @State private var isImporting: Bool = false
    @State private var modelImported: Bool = false
    let binType = UTType(tag: "txt", tagClass: .filenameExtension, conformingTo: nil)
    let ggufType = UTType(tag: "pdf", tagClass: .filenameExtension, conformingTo: nil)
    @State private var docFileUrl: URL = URL(filePath: "")
    @State private var docFileName: String = ""
    @State private var docFilePath: String = "select model"
    @State private var addButtonIcon: String = "plus.app"
    @State private var isIndexUpdatePopoverPresented: Bool = false
    @State private var importStatus = ""

    var ragUrl:URL
    @State var ragDir: String
    @Binding private var chunkSize: Int 
    @Binding private var chunkOverlap: Int 
    @Binding private var currentModel: EmbeddingModelType 
    @Binding private var comparisonAlgorithm: SimilarityMetricType 
    @Binding private var chunkMethod: TextSplitterType 

    // サポートするファイル形式を定義
    private let targetExts = [
        // テキストファイル
        ".txt", ".md", ".rtf",
        // ドキュメント
        ".pdf", ".doc", ".docx",
        // プレゼンテーション
        ".ppt", ".pptx",
        // スプレッドシート
        ".csv", ".xls", ".xlsx",
        // その他
        ".json", ".xml"
    ]
    
    // ファイルタイプに応じたアイコンを返す
    private func getFileIcon(_ ext: String) -> String {
        switch ext.lowercased() {
        case ".txt", ".md", ".rtf":
            return "doc.text"
        case ".pdf":
            return "doc.pdf"
        case ".doc", ".docx":
            return "doc.word"
        case ".ppt", ".pptx":
            return "doc.ppt"
        case ".csv", ".xls", ".xlsx":
            return "doc.excel"
        case ".json", ".xml":
            return "doc.code"
        default:
            return "doc"
        }
    }
    
    // ファイルサイズのフォーマット
    private func formatFileSize(_ size: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
    
    init (  docsDir:String,
            ragDir:String,
            chunkSize: Binding<Int>,
            chunkOverlap: Binding<Int>,
            currentModel: Binding<EmbeddingModelType>,
            comparisonAlgorithm: Binding<SimilarityMetricType>,
            chunkMethod: Binding<TextSplitterType>){
        self.dir = docsDir
        self._docsPreviews = State(initialValue: getFileListByExts(dir:dir,exts:targetExts)!)
        self.ragDir = ragDir
        self.ragUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(ragDir) ?? URL(fileURLWithPath: "")        
        self._chunkSize = chunkSize
        self._chunkOverlap = chunkOverlap
        self._currentModel = currentModel
        self._comparisonAlgorithm = comparisonAlgorithm
        self._chunkMethod  = chunkMethod
    }
    
    func delete(at offsets: IndexSet) {
        let fileToDelete = offsets.map { self.docsPreviews[$0] }
        _ = removeFile(fileToDelete,dest:dir)
        docsPreviews = getFileListByExts(dir:dir,exts:targetExts) ?? []
        let fname = fileToDelete.first?["file_name"]
        Task {
           await removeFileFromIndex(fileName: fname, ragURL: ragUrl)
        }
    }
    
    func delete(at elem:Dictionary<String, String>){
        _  = removeFile([elem],dest:dir)
        self.docsPreviews.removeAll(where: { $0 == elem })
        let fname = elem["file_name"]
        docsPreviews = getFileListByExts(dir:dir,exts:targetExts) ?? []
        Task {
           await removeFileFromIndex(fileName: fname, ragURL: ragUrl)
        }
    }
    
    private func delayIconChange() {
        // Delay of 7.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            addButtonIcon = "plus.app"
        }
    }
    
    
    
    var body: some View {
        //        ZStack{
        //            Color("color_bg").edgesIgnoringSafeArea(.all)
        GroupBox(label:
                 Text("Documents for RAG")
        ) {
            HStack{
                Spacer()
                Button {
                    Task {
                        isImporting.toggle()
                    }
                    
                } label: {
                    Image(systemName: addButtonIcon)
                    //                            .foregroundColor(Color("color_primary"))
                        .font(.title2)
                }
                .buttonStyle(.borderless)
                .frame(alignment: .trailing)
                .padding([.top,.trailing])
                //                .controlSize(.large)
                .fileImporter(
                    isPresented: $isImporting,
                    allowedContentTypes: [.data, .directory],
                    allowsMultipleSelection: true
                ) { result in
                    Task {
                        do {
                            let selectedFiles = try result.get()
                            importStatus = ""
                            isIndexUpdatePopoverPresented = true
                            var importedCount = 0
                            
                            for selectedFile in selectedFiles {
                                let isDirectory = try selectedFile.resourceValues(forKeys: [.isDirectoryKey]).isDirectory ?? false
                                
                                if isDirectory {
                                    importStatus = "インポート中: \(selectedFile.lastPathComponent)内のファイル"
                                    let fileManager = FileManager.default
                                    let files = try fileManager.contentsOfDirectory(at: selectedFile, includingPropertiesForKeys: nil)
                                    
                                    for file in files {
                                        let ext = "." + file.pathExtension.lowercased()
                                        if targetExts.contains(where: { $0.lowercased() == ext }) {
                                            importStatus = "コピー中: \(file.lastPathComponent)"
                                            _ = CopyFileToSandbox(url: file, dest: dir)
                                            
                                            importStatus = "インデックス追加中: \(file.lastPathComponent)"
                                            await addFileToIndex(fileURL: file, 
                                                              ragURL: ragUrl,
                                                              currentModel: currentModel,
                                                              comparisonAlgorithm: comparisonAlgorithm,
                                                              chunkMethod: chunkMethod)
                                            importedCount += 1
                                        }
                                    }
                                } else {
                                    let ext = "." + selectedFile.pathExtension.lowercased()
                                    if targetExts.contains(where: { $0.lowercased() == ext }) {
                                        importStatus = "コピー中: \(selectedFile.lastPathComponent)"
                                        _ = CopyFileToSandbox(url: selectedFile, dest: dir)
                                        
                                        importStatus = "インデックス追加中: \(selectedFile.lastPathComponent)"
                                        await addFileToIndex(fileURL: selectedFile, 
                                                          ragURL: ragUrl,
                                                          currentModel: currentModel,
                                                          comparisonAlgorithm: comparisonAlgorithm,
                                                          chunkMethod: chunkMethod)
                                        importedCount += 1
                                    } else {
                                        importStatus = "サポートされていない形式: \(selectedFile.lastPathComponent)"
                                        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5秒待機
                                        continue
                                    }
                                }
                            }
                            
                            if importedCount > 0 {
                                modelImported = true
                                addButtonIcon = "checkmark"
                                delayIconChange()
                                docsPreviews = getFileListByExts(dir: dir, exts: targetExts) ?? []
                                importStatus = "インポート完了"
                                try await Task.sleep(nanoseconds: 1_000_000_000) // 1秒待機
                            }
                            
                            isIndexUpdatePopoverPresented = false
                            
                        } catch {
                            print("Unable to read file contents")
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            VStack{
//                VStack(spacing: 5){
                    List(selection: $docSelection){
                        ForEach(docsPreviews, id: \.self) { model in
                            ModelInfoItem(
                                modelIcon: String(describing: model["icon"]!),
                                file_name: String(describing: model["file_name"]!),
                                orig_file_name: String(describing: model["file_name"]!),
                                size: String(describing: model["size"]!),
                                date: String(describing: model["date"]!)
                            ).contextMenu {
                                Button(action: {
                                    delete(at: model)
                                }){
                                    Text("Delete")
                                }
                            }
                        }
                        .onDelete(perform: delete)
                        .listRowBackground(Color.gray.opacity(0))
                        
                    }
                    .scrollContentBackground(.hidden)
                    
                    .onAppear {
                        docsPreviews = getFileListByExts(dir:dir,exts:targetExts)  ?? []
                    }
#if os(macOS)
                    .listStyle(.sidebar)
#else
                    .listStyle(InsetListStyle())
#endif
//                }
                if  docsPreviews.count <= 0 {
                    VStack{
                        
                        Button {
                            Task {
                                isImporting.toggle()
                            }
                        } label: {
                            Image(systemName: "plus.square.dashed")
                                .foregroundColor(.secondary)
                                .font(.system(size: 40))
                        }
                        .buttonStyle(.borderless)
                        .controlSize(.large)
                        Text("Add file")
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                        
                    }.opacity(0.4)
                        .frame(maxWidth: .infinity,alignment: .center)
                }
                
            }
            .frame(maxHeight: .infinity)
        }
        .sheet(isPresented: $isIndexUpdatePopoverPresented) {
            indexUpdatePopoverContent(importStatus: $importStatus)/*(selection: $selectedEmoji)*/
                .presentationDetents([.height(200)])
//                .presentationCompactAdaptation(.sheet)
        }
        
//        .padding(.horizontal,10)
//        .toolbar{
//
//        }
        //        .navigationTitle(dir)
        .onChange(of:dir){ dir in
            docsPreviews = getFileListByExts(dir:dir,exts:targetExts)  ?? []
        }
    }
//    }
}

//struct ContactsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ModelsView()
//    }
//}



//#Preview {
//    DocsView()
//}
