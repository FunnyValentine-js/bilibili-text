//
//  HomeView.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/5/23.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = VideoViewModel(
        databasePath: NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        ).first! + "/videos.db"
    )
    
    @State private var selectedTab = 1
    @State private var offset: CGFloat = 0
    private let tabs = [
        (id: 0, name: "直播"),
        (id: 1, name: "推荐"),
        (id: 2, name: "热门"),
        (id: 3, name: "动画"),
        (id: 4, name: "影视")
    ]
    
    var body: some View {
        VStack {
            NavigationLink(destination: VideoSearchView(viewModel: viewModel)) {
                Image("Search")
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()
                    .edgesIgnoringSafeArea(.top)
                    .padding(.bottom, 0)
            }
            
            // 顶部导航栏分区
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 40) {
                    ForEach(tabs, id: \.id) { tab in
                        VStack(spacing: 3) {
                            Text(tab.name)
                                .font(.system(size: 20, weight: selectedTab == tab.id ? .bold : .regular))
                                .foregroundColor(selectedTab == tab.id ? .pink : .gray)
                            
                            if selectedTab == tab.id {
                                Color.pink
                                    .frame(width: 30, height: 5)
                                    .cornerRadius(1.5)
                            } else {
                                Color.clear
                                    .frame(height: 5)
                            }
                        }
                        .frame(width: 40)
                        .onTapGesture {
                            withAnimation {
                                selectedTab = tab.id
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 20)
            .background(Color(.systemBackground))
            
            // 内容区域
            TabView(selection: $selectedTab) {
                LiveContentView().tag(0)
                RecommendView().tag(1)
                HotContentView().tag(2)
                AnimeContentView().tag(3)
                MovieContentView().tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: UIScreen.main.bounds.height - 240)
            .offset(x: offset)
        }
    }
}
 

// 其他分区内容占位视图
struct LiveContentView: View {
    var body: some View {
        VStack {
            Image("Live")
                .resizable()
                .scaledToFit()
            Spacer()
        }
    }
}

struct HotContentView: View {
    var body: some View {
        VStack {
            Image("Hot")
                .resizable()
                .scaledToFit()
            Spacer()
        }
    }
}
        
struct AnimeContentView: View {
    var body: some View {
        VStack {
            Image("Anime")
                .resizable()
                .scaledToFit()
            Spacer()
        }
    }
}

struct MovieContentView: View {
    var body: some View {
        VStack {
            Image("Movie")
                .resizable()
                .scaledToFit()
            Spacer()
        }
    }
}
    

