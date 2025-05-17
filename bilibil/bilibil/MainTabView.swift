//
//  MainTabView.swift
//  bilibil
//
//  Created by SOSD_M1_2 on 2025/4/24.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 首页
            HomeView()
                .tabItem {
                    if selectedTab == 0 {
                        Image(systemName: "house.fill")
                    } else {
                        Image(systemName: "house")
                    }
                    Text("首页")
                }
                .tag(0)
            
            // 动态
            DynamicView()
                .tabItem {
                    if selectedTab == 1 {
                        Image(systemName: "bell.fill")
                    } else {
                        Image(systemName: "bell")
                    }
                    Text("动态")
                }
                .tag(1)
            
            // 创作 - 特殊红色加号按钮
            CreationView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                        .renderingMode(.template)
                }
                .tag(2)
            
            // 会员购
            ShopView()
                .tabItem {
                    if selectedTab == 3 {
                        Image(systemName: "cart.fill")
                    } else {
                        Image(systemName: "cart")
                    }
                    Text("会员购")
                }
                .tag(3)
            
            // 我的
            ContentView()
                .tabItem {
                    if selectedTab == 4 {
                        Image(systemName: "person.circle.fill")
                    } else {
                        Image(systemName: "person.circle")
                    }
                    Text("我的")
                }
                .tag(4)
        }
        .accentColor(.pink) // 设置主题色为红色
        .onAppear {
            // 设置创作按钮的颜色
            UITabBar.appearance().tintColor = .red
        }
    }
}

#Preview {
    MainTabView()
}
