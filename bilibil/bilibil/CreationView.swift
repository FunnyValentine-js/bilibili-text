//
//  CreationView.swift
//  bilibil
//
//  Created by SOSD_M1_2 on 2025/4/25.
//

import SwiftUI

/**
 * @file CreationView.swift
 * @description 创作中心页面，提供投稿、拍摄、上传等入口。
 * @author SOSD_M1_2
 * @date 2025/4/25
 */

/**
 * @struct CreationView
 * @description 创作中心主页面，包含创作按钮列表。
 */
struct CreationView: View {
    var body: some View {
        NavigationView {
            VStack {
                /**
                 * 页面标题。
                 */
                Text("创作中心")
                    .font(.title)
                    .padding()
                
                /**
                 * 创作按钮区，包含投稿、拍摄、上传等。
                 */
                VStack(spacing: 20) {
                    CreationButton(icon: "video.fill", label: "投稿视频")
                    CreationButton(icon: "camera.fill", label: "拍摄视频")
                    CreationButton(icon: "photo.fill", label: "上传照片")
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("创作")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

/**
 * @struct CreationButton
 * @description 创作中心单个操作按钮。
 * @property {String} icon 按钮图标（SF Symbol）。
 * @property {String} label 按钮文字。
 */
struct CreationButton: View {
    let icon: String
    let label: String
    
    var body: some View {
        Button(action: {}) {
            HStack {
                // 图标
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                
                // 文字
                Text(label)
                    .foregroundColor(.white)
                    .font(.headline)
                
                Spacer()
                // 右箭头
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .cornerRadius(8)
        }
    }
}

#Preview {
    CreationView()
}
