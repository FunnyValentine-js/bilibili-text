//
//  DetailVideoCard.swift
//  bilibil
//
//  Created by SOSD_M1_2 on 2025/4/25.
//

import SwiftUI

struct DetailVideoCard: View {
    let title: String
    let author: String
    let views: String
    let coverImage: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Thumbnail
            Image(systemName: coverImage)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 70)
                .clipped()
                .cornerRadius(6)
                .foregroundColor(.white)
                .background(Color.gray.opacity(0.3))
            
            // Video info
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text(author)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(views)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
    }
}

