//
//
//  ChatItem.swift
//  Created by guinmoon
//


import SwiftUI



struct ChatItem: View {
    
    var chatImage: String = ""
    var chatTitle: String = ""
    var message: String = ""
    var time: String = ""
    var model: String = ""
    var chat: String = ""
    var model_size: String = ""
    //    @Binding var chat_selection: String?
    @Binding var model_name: String
    @Binding var title: String
    var close_chat: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Text(chatImage)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(Color.accentColor.opacity(0.1))
                )
                .overlay(
                    Circle()
                        .stroke(Color.accentColor.opacity(0.2), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(chatTitle)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(
                    color: .black.opacity(0.05),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
    }
}
