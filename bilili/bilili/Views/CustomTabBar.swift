//
//  CustomTabBar.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/5/23.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            TabButton(image: "house.fill", title: "首页", tag: 0, selectedTab: $selectedTab)
            TabButton(image: "bell.fill", title: "动态", tag: 1, selectedTab: $selectedTab)
            
            // 中间的Tab项，使用大图片
            Button(action: {
                selectedTab = 2
            }) {
                Image(systemName: "plus.app.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 45)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(10)
                    
                    
            }
            .frame(maxHeight: .infinity)
            
            TabButton(image: "cart.fill", title: "会员购", tag: 3, selectedTab: $selectedTab)
            TabButton(image: "person.circle.fill", title: "我的", tag: 4, selectedTab: $selectedTab)
        }
        .frame(height: 80)
        .background(Color.white)
        //.clipShape(Capsule())
        
    }
}

