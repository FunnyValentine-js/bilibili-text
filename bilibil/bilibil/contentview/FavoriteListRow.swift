//
//  FavoriteListRow.swift
//  bilibil
//
//  Created by SOSD_M1_2 on 2025/4/25.
//

import SwiftUI

/**
 * @file FavoriteListRow.swift
 * @description 收藏夹列表单元，展示收藏夹封面、名称、视频数量。
 * @author SOSD_M1_2
 * @date 2025/4/25
 */

/**
 * @struct FavoriteListRow
 * @description 收藏夹列表单元组件。
 * @property {Int} favoriteId 收藏夹ID。
 * @property {String} title 收藏夹名称。
 * @property {DatabaseManager} dbManager 数据库管理器。
 * @property {String?} firstVideoCover 收藏夹第一个视频封面。
 * @property {Int} videoCount 收藏夹视频数量。
 */
struct FavoriteListRow: View {
    let favoriteId: Int
    let title: String
    let dbManager: DatabaseManager
    
    @State private var firstVideoCover: String? = nil
    @State private var videoCount: Int = 0
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            /**
             * 封面图片，优先显示第一个视频封面，否则显示文件夹图标。
             */
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
            
            /**
             * 收藏夹信息：名称和视频数量。
             */
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
