//
//  CustomTabBar.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/5/23.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Binding var isStatusBarHidden: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            
            TabButton(image: "house.fill", title: "首页", tag: 0, selectedTab: $selectedTab)
                .onTapGesture { isStatusBarHidden = false }
                .padding(.leading,10)
            TabButton(image: "bell.fill", title: "动态", tag: 1, selectedTab: $selectedTab)
                .onTapGesture { isStatusBarHidden = true }
            
            // 中间的Tab项，使用大图片
            Button(action: {
                selectedTab = 2
                isStatusBarHidden = false
            }) {
                Image(systemName: "plus.app.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 45)
                    .clipShape(RoundedRectangle(cornerRadius: 17))
                    .padding(.horizontal,5)
            }
            .frame(maxHeight: .infinity)
            
            TabButton(image: "cart.fill", title: "会员购", tag: 3, selectedTab: $selectedTab)
                .onTapGesture { isStatusBarHidden = true }
            TabButton(image: "person.circle.fill", title: "我的", tag: 4, selectedTab: $selectedTab)
                .onTapGesture { isStatusBarHidden = false }
                .padding(.trailing,10)
            
        }
        .frame(height: 40)
        .background(Color.white)
        //.clipShape(Capsule())
        .onChange(of: selectedTab) { newValue in
            print("Tab切换: selectedTab = \(newValue)")
        }
    }
}

