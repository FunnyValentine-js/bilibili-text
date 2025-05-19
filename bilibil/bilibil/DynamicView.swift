//
//  DynamicView.swift
//  bilibil
//
//  Created by SOSD_M1_2 on 2025/4/25.
//

import SwiftUI

/**
 * @file DynamicView.swift
 * @description 动态页面，展示UP主的最新动态信息。
 * @author SOSD_M1_2
 * @date 2025/4/25
 */

/**
 * @struct DynamicView
 * @description 动态主页面，包含动态列表。
 */
struct DynamicView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    /**
                     * 顶部提示文字。
                     */
                    Text("动态页面内容")
                        .padding()
                    
                    /**
                     * 动态卡片列表，模拟5条UP主动态。
                     */
                    ForEach(0..<5) { index in
                        DynamicCardView(content: "UP主 \(index+1) 更新了视频 \(index+1)")
                    }
                }
            }
            .navigationTitle("动态")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

/**
 * @struct DynamicCardView
 * @description 单条动态卡片，展示UP主头像、内容、时间等。
 * @property {String} content 动态内容。
 */
struct DynamicCardView: View {
    let content: String
    
    var body: some View {
        HStack(alignment: .top) {
            // UP主头像（灰色圆形）
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading) {
                // 动态内容
                Text(content)
                    .font(.subheadline)
                
                HStack {
                    // 时间
                    Text("2小时前")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    // 更多操作
                    Image(systemName: "ellipsis")
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    DynamicView()
}
