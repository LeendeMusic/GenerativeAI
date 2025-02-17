//
//  SettingsMenuItem.swift
//  ChatUI
//
//  Created by Guinmoon
//

import SwiftUI

struct SettingsMenuItem: View {
    
    public var icon:String
    public var name:String
    @Binding var current_detail_view_name:String?


    var body: some View {
        Button(action: {
            current_detail_view_name = name
        }) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.accentColor)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color.accentColor.opacity(0.1))
                    )
                
                Text(name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: .black.opacity(0.05),
                        radius: 6,
                        x: 0,
                        y: 2
                    )
            )
        }
    }
}
