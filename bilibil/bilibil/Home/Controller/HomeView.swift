//
//  HomeView.swift
//  bilibil
//
//  Created by SOSD_M1_2 on 2025/4/25.
//

import SwiftUI
import Combine

/**
 * @file HomeView.swift
 * @description 首页主界面，包含顶部搜索、分区Tab、视频推荐等内容。
 * @author SOSD_M1_2
 * @date 2025/4/25
 */

/**
 * @struct HomeView
 * @description 首页视图，展示推荐视频、分区切换、顶部搜索等。
 * @property {DatabaseManager} dbManager 数据库管理器，用于视频数据的增删查。
 * @property {Array} allVideos 所有视频数据。
 * @property {Array} displayedVideos 当前展示的视频数据（分页）。
 * @property {Int} selectedTab 当前选中的分区Tab。
 * @property {CGFloat} offset 滑动偏移量，用于手势切换分区。
 * @property {Int} currentPage 当前分页页码。
 * @property {Bool} hasMoreVideos 是否还有更多视频可加载。
 * @property {Int} pageSize 每页视频数量。
 * @property {Array} tabs 分区Tab配置。
 * @property {Array} sampleVideos 示例视频数据。
 */
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                /**
                 * 顶部搜索栏，点击跳转到搜索页面。
                 */
                NavigationLink(destination: SearchView(dbManager: viewModel.dbManager)) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        Text("搜索视频")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .buttonStyle(PlainButtonStyle())
                
                /**
                 * 顶部分区Tab栏，支持横向滑动和点击切换。
                 */
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(viewModel.tabs, id: \.id) { tab in
                            VStack {
                                Text(tab.name)
                                    .font(.system(size: 16, weight: viewModel.selectedTab == tab.id ? .bold : .regular))
                                    .foregroundColor(viewModel.selectedTab == tab.id ? .black : .gray)
                                
                                if viewModel.selectedTab == tab.id {
                                    Color.blue
                                        .frame(height: 3)
                                        .cornerRadius(1.5)
                                } else {
                                    Color.clear
                                        .frame(height: 3)
                                }
                            }
                            .frame(width: 60)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.selectedTab = tab.id
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .frame(height: 40)
                .background(Color(.systemBackground))
                
                /**
                 * 内容区域，分区内容通过TabView切换。
                 * 推荐区支持分页加载视频。
                 */
                TabView(selection: $viewModel.selectedTab) {
                    LiveContentView().tag(0)
                    
                    ScrollView {
                        // 使用LazyVGrid实现视频卡片瀑布流布局
                        LazyVGrid(columns: [GridItem(), GridItem()], spacing: 20) {
                            ForEach(viewModel.displayedVideos, id: \.id) { video in
                                NavigationLink(destination: VideoDetailView(video: video)) {
                                    VideoCardView(
                                        title: video.name,
                                        author: "UP主 \(video.id)",
                                        views: "\(Int.random(in: 1000...10000))观看",
                                        coverImage: video.coverImage
                                    )
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        // 加载更多指示器
                        if viewModel.hasMoreVideos {
                            ProgressView()
                                .padding()
                                .onAppear {
                                    viewModel.loadMoreVideos()
                                }
                        } else {
                            Text("已经滑到底部了")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    .padding()
                    .tag(1)
                    
                    HotContentView().tag(2)
                    AnimeContentView().tag(3)
                    MovieContentView().tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: UIScreen.main.bounds.height - 240)
                .offset(x: viewModel.offset)
                .gesture(
                    DragGesture()
                        .onChanged { viewModel.offset = $0.translation.width }
                        .onEnded { viewModel.handleSwipe($0) }
                )
            }
            .navigationTitle("首页")
            .navigationBarHidden(true)
            .onAppear {
                viewModel.onAppear()
            }
        }
    }
}

struct VideoCardView: View {
    let title: String
    let author: String
    let views: String
    let coverImage: String
    
    var body: some View {
        VStack(alignment: .leading) {
            // 视频缩略图 - 使用SF Symbol或系统图片
            Image(systemName: coverImage)
                .resizable()
                .scaledToFit()
                .frame(height: 180)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(8)
            
            // 视频信息
            HStack(alignment: .top) {
                // UP主头像
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text(author)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text(views)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.top, 8)
        }
        .padding(.bottom, 8)
    }
}


struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// 其他分区内容占位视图
struct LiveContentView: View {
    var body: some View {
        VStack {
            Text("直播内容区域")
                .font(.title)
                .padding()
            Spacer()
        }
    }
}

struct HotContentView: View {
    var body: some View {
        VStack {
            Text("热门内容区域")
                .font(.title)
                .padding()
            Spacer()
        }
    }
}

struct AnimeContentView: View {
    var body: some View {
        VStack {
            Text("动画内容区域")
                .font(.title)
                .padding()
            Spacer()
        }
    }
}

struct MovieContentView: View {
    var body: some View {
        VStack {
            Text("影视内容区域")
                .font(.title)
                .padding()
            Spacer()
        }
    }
}




struct SearchView: View {
    @ObservedObject var dbManager: DatabaseManager
    @State private var searchText = ""
    @State private var searchResults: [(id: Int, name: String, coverImage: String)] = []
    @State private var isSearching = false
    @State private var searchHistory: [String] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // 固定在顶部的搜索栏
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("输入搜索关键词", text: $searchText, onCommit: {
                    performSearch()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        searchResults = []
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            
            // 历史搜索记录（仅在无搜索结果且无输入时显示）
            if !searchHistory.isEmpty && searchText.isEmpty && searchResults.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Text("历史搜索")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    
                    List {
                        ForEach(searchHistory, id: \.self) { history in
                            Button(action: {
                                searchText = history
                                performSearch()
                            }) {
                                HStack {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .foregroundColor(.gray)
                                    Text(history)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                            }
                        }
                        .onDelete(perform: deleteHistory)
                    }
                    .listStyle(PlainListStyle())
                    .frame(height: CGFloat(min(searchHistory.count, 5)) * 44) // 限制高度显示最多5条
                }
                .padding(.top, 0)
            }
            
            // 搜索结果或空白状态
            if isSearching {
                ProgressView()
                    .padding()
                Spacer()
            } else if !searchResults.isEmpty {
                List {
                    ForEach(searchResults, id: \.id) { video in
                        NavigationLink(destination: VideoDetailView(video: video)) {
                            HStack {
                                Image(systemName: video.coverImage)
                                    .resizable()
                                    .frame(width: 60, height: 40)
                                    .foregroundColor(.white)
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(4)
                                
                                VStack(alignment: .leading) {
                                    Text(video.name)
                                        .font(.subheadline)
                                    Text("UP主 \(video.id)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            } else if !searchText.isEmpty {
                Text("没有找到相关视频")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else if searchHistory.isEmpty {
                Spacer()
                Text("输入关键词搜索视频")
                    .foregroundColor(.gray)
                Spacer()
            }
            Spacer()
        }
        .navigationTitle("搜索")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSearchHistory()
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        addToSearchHistory(searchText)
        isSearching = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let allVideos = dbManager.getAllVideos()
            searchResults = allVideos.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                String($0.id).contains(searchText)
            }
            isSearching = false
        }
    }
    
    private func loadSearchHistory() {
        searchHistory = UserDefaults.standard.stringArray(forKey: "searchHistory") ?? []
    }
    
    private func addToSearchHistory(_ term: String) {
        searchHistory.removeAll { $0 == term }
        searchHistory.insert(term, at: 0)
        if searchHistory.count > 5 {
            searchHistory = Array(searchHistory.prefix(5))
        }
        UserDefaults.standard.set(searchHistory, forKey: "searchHistory")
    }
    
    private func deleteHistory(at offsets: IndexSet) {
        searchHistory.remove(atOffsets: offsets)
        UserDefaults.standard.set(searchHistory, forKey: "searchHistory")
    }
}

//#Preview {
//    HomeView()
//}
