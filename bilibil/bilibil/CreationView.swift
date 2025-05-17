//
//  CreationView.swift
//  bilibil
//
//  Created by SOSD_M1_2 on 2025/4/25.
//

import SwiftUI

struct CreationView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("创作中心")
                    .font(.title)
                    .padding()
                
                // 模拟创作按钮
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

struct CreationButton: View {
    let icon: String
    let label: String
    
    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                
                Text(label)
                    .foregroundColor(.white)
                    .font(.headline)
                
                Spacer()
                
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
