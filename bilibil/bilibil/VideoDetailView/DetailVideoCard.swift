//
//  DetailVideoCard.swift
//  bilibil
//
//  Created by SOSD_M1_2 on 2025/4/25.
//

import SwiftUI

/**
 * @file DetailVideoCard.swift
 * @description 视频详情页中的视频卡片组件。
 * @author SOSD_M1_2
 * @date 2025/4/25
 */

/**
 * @struct DetailVideoCard
 * @description 视频卡片组件，展示视频封面、标题、作者、播放量。
 * @property {String} title 视频标题。
 * @property {String} author 作者。
 * @property {String} views 播放量。
 * @property {String} coverImage 封面图片（SF Symbol）。
 */
struct DetailVideoCard: View {
    let title: String
    let author: String
    let views: String
    let coverImage: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            /**
             * 视频封面缩略图。
             */
            Image(systemName: coverImage)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 70)
                .clipped()
                .cornerRadius(6)
                .foregroundColor(.white)
                .background(Color.gray.opacity(0.3))
            
            /**
             * 视频信息区：标题、作者、播放量。
             */
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

