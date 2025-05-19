//
//  MainTabView.swift
//  bilibil
//
//  Created by SOSD_M1_2 on 2025/4/24.
//

import SwiftUI

/**
 * @file MainTabView.swift
 * @description 应用主界面底部Tab栏视图，负责切换各个主要功能页面。
 * @author SOSD_M1_2
 * @date 2025/4/24
 */

/**
 * @struct MainTabView
 * @description 主Tab栏视图，包含首页、动态、创作、会员购、我的五个Tab。
 * @property {Int} selectedTab 当前选中的Tab索引。
 */
struct MainTabView: View {
    /**
     * @state 当前选中的Tab索引，默认选中首页（0）。
     */
    @State private var selectedTab = 0
    
    var body: some View {
        /**
         * TabView用于实现底部导航栏，绑定selectedTab以实现Tab切换。
         * 每个Tab对应一个页面视图。
         */
        TabView(selection: $selectedTab) {
            // 首页Tab
            HomeView()
                .tabItem {
                    // 选中时为实心房子，未选中为空心房子
                    if selectedTab == 0 {
                        Image(systemName: "house.fill")
                    } else {
                        Image(systemName: "house")
                    }
                    Text("首页")
                }
                .tag(0)
            
            // 动态Tab
            DynamicView()
                .tabItem {
                    // 选中时为实心铃铛，未选中为空心铃铛
                    if selectedTab == 1 {
                        Image(systemName: "bell.fill")
                    } else {
                        Image(systemName: "bell")
                    }
                    Text("动态")
                }
                .tag(1)
            
            // 创作Tab（中间特殊红色加号按钮）
            CreationView()
                .tabItem {
                    // 只显示红色加号，无文字
                    Image(systemName: "plus.circle.fill")
                        .renderingMode(.template)
                }
                .tag(2)
            
            // 会员购Tab
            ShopView()
                .tabItem {
                    // 选中时为实心购物车，未选中为空心购物车
                    if selectedTab == 3 {
                        Image(systemName: "cart.fill")
                    } else {
                        Image(systemName: "cart")
                    }
                    Text("会员购")
                }
                .tag(3)
            
            // 我的Tab
            ContentView()
                .tabItem {
                    // 选中时为实心头像，未选中为空心头像
                    if selectedTab == 4 {
                        Image(systemName: "person.circle.fill")
                    } else {
                        Image(systemName: "person.circle")
                    }
                    Text("我的")
                }
                .tag(4)
        }
        // 设置Tab栏主题色为粉色
        .accentColor(.pink)
        .onAppear {
            // 设置Tab栏选中项颜色为红色（仅对UIKit生效，SwiftUI下部分版本无效）
            UITabBar.appearance().tintColor = .red
        }
    }
}

/**
 * @description 预览MainTabView组件。
 */
#Preview {
    MainTabView()
}
