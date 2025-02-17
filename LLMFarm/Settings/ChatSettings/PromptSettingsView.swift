//
//  PromptSettingsView.swift
//  LocalMind
//
//  Created by guinmoon on 22.06.2024.
//

import SwiftUI

struct PromptSettingsView: View {
    @Binding var prompt_format: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextEditor(text: $prompt_format)
                .frame(minHeight: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2))
                )
            
            Text("example: You are a helpful assistant. {{prompt}}")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
}
//
//#Preview {
//    PromptSettingsView()
//}
