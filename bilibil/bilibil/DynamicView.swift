//
//  DynamicView.swift
//  bilibil
//
//  Created by SOSD_M1_2 on 2025/4/25.
//

import SwiftUI

struct DynamicView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("动态页面内容")
                        .padding()
                    
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

struct DynamicCardView: View {
    let content: String
    
    var body: some View {
        HStack(alignment: .top) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading) {
                Text(content)
                    .font(.subheadline)
                
                HStack {
                    Text("2小时前")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
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
