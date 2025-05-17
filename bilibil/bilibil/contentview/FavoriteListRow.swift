//
//  FavoriteListRow.swift
//  bilibil
//
//  Created by SOSD_M1_2 on 2025/4/25.
//

import SwiftUI

struct FavoriteListRow: View {
    let favoriteId: Int
    let title: String
    let dbManager: DatabaseManager
    
    @State private var firstVideoCover: String? = nil
    @State private var videoCount: Int = 0
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // 封面图片
            if let cover = firstVideoCover {
                Image(systemName: cover)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 60)
                    .clipped()
                    .cornerRadius(6)
                    .foregroundColor(.white)
                    .background(Color.gray.opacity(0.3))
            } else {
                Color.gray.opacity(0.3)
                    .frame(width: 80, height: 60)
                    .cornerRadius(6)
                    .overlay(
                        Image(systemName: "folder")
                            .foregroundColor(.white)
                            .font(.title2)
                    )
            }
            
            // 收藏夹信息
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .lineLimit(1)
                
                Text("\(videoCount)个视频")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // 右侧箭头
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onAppear {
            let videos = dbManager.getVideosInFavoriteList(favoriteId: favoriteId)
            firstVideoCover = videos.first?.coverImage
            videoCount = videos.count
        }
    }
}
