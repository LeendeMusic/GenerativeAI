//
//  TabsView.swift
//  LocalMind
//
//  Created by guinmoon on 18.10.2024.
//

import SwiftUI



struct ChatSettingTabs : View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var index:Int
    @Binding var edit_chat_dialog:Bool
    
    var body: some View{
        VStack(spacing: 16) {
            TabButton(index: $index, targetIndex: 0, 
                      image: Image(systemName: "gearshape.fill"), text: "General")
#if os(macOS)
                .padding(.top, topSafeAreaInset())
#else
                .padding(.top, UIApplication.shared.keyWindow?.safeAreaInsets.top)
#endif
            
            TabButton(index: $index, targetIndex: 1, 
                      image: Image(systemName: "text.word.spacing"), text: "Prompt")
            
            if edit_chat_dialog {
                TabButton(index: $index, targetIndex: 5, 
                          image: Image(systemName: "doc.on.doc.fill"), text: "RAG")
            }
            
            Spacer()
        }
        .padding(.vertical)
        .frame(width: 70)
        .background(
            Color(.systemBackground)
                .opacity(0.8)
                .blur(radius: 10)
        )
        .clipShape(CShape())
    }
}


