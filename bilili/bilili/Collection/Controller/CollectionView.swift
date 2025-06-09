//
//  CollectionView.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/5/23.
//

import SwiftUI

struct CollectionView: View {
    var body: some View {
        VStack {
            Text("Welcome to the Collection View")
                .font(.title)
            // 在这里添加CollectionView的内容
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // 使图片最大化
        
        
    }
}

#Preview {
    CollectionView()
}
