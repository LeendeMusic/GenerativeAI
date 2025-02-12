//
//  ContactItem.swift
//  ChatUI
//
//  Created by Shezad Ahamed on 6/08/21.
//

import SwiftUI

struct ModelInfoItem: View {
    
    var modelIcon: String = ""
    @State var file_name: String = ""
    @State var orig_file_name: String = ""
    var description: String = ""
    var size: String = ""
    var date: String = ""
    
    var body: some View {
        HStack {
            Image(systemName: modelIcon)
                .resizable()
                .padding(EdgeInsets(top: 7, leading: 5, bottom: 7, trailing: 5))
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6) {
                Text(file_name)
                    .fontWeight(.medium)
                
                HStack {
                    Text(size)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 10)
            
            Spacer()
        }
    }
}
