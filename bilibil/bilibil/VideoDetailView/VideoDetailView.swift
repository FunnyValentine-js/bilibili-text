//
//  VideoDetailView.swift
//  bilibil
//
//  Created by SOSD_M1_2 on 2025/4/25.
//

import SwiftUI

struct VideoDetailView: View {
    let video: (id: Int, name: String, coverImage: String)
        @State private var dbManager = DatabaseManager()
        @State private var favoriteLists: [(id: Int, name: String)] = []
        @State private var showFavoriteSheet = false
        @State private var showSuccessAlert = false
        @State private var successMessage = ""
        @State private var isVideoFavorited = false
        @State private var allVideos: [(id: Int, name: String, coverImage: String)] = []
        
        var relatedVideos: [(id: Int, name: String, coverImage: String)] {
            allVideos.filter { $0.id != video.id } // 排除当前视频
        }
        
        var body: some View {
            ScrollView {
                VStack(spacing: 0) {
                    // 上半部分：当前视频详情
                    VStack {
                        Image(systemName: video.coverImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.3))
                        
                        Text(video.name)
                            .font(.title)
                            .padding()
                        
                        Text("UP主 \(video.id)")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 20)
                    
                    // 分割线
                    Divider()
                        .padding(.horizontal)
                    
                    // 下半部分：相关视频列表
                    VStack(alignment: .leading, spacing: 0) {
                        Text("相关推荐")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                        
                        LazyVStack(spacing: 16) {
                            ForEach(relatedVideos, id: \.id) { relatedVideo in
                                NavigationLink(destination: VideoDetailView(video: relatedVideo)) {
                                    DetailVideoCard(
                                        title: relatedVideo.name,
                                        author: "UP主 \(relatedVideo.id)",
                                        views: "\(Int.random(in: 1000...10000))观看",
                                        coverImage: relatedVideo.coverImage
                                    )
                                    .padding(.horizontal)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 30)
                    }
                    .background(Color(.systemBackground))
                }
            }
            .navigationTitle("视频详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: toggleFavorite) {
                        Image(systemName: isVideoFavorited ? "star.fill" : "star")
                            .foregroundColor(isVideoFavorited ? .yellow : .gray)
                    }
                    .contextMenu {
                        Button(action: { showFavoriteSheet = true }) {
                            Label("管理收藏", systemImage: "folder")
                        }
                    }
                }
            }
            .sheet(isPresented: $showFavoriteSheet) {
                FavoriteSelectionView(
                    videoId: video.id,
                    favoriteLists: favoriteLists,
                    isVideoFavorited: isVideoFavorited,
                    dbManager: dbManager,
                    onComplete: { message in
                        successMessage = message
                        showSuccessAlert = true
                        checkFavoriteStatus()
                    }
                )
            }
            .alert("操作提示", isPresented: $showSuccessAlert) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(successMessage)
            }
            .onAppear {
                favoriteLists = dbManager.getAllFavoriteLists()
                allVideos = dbManager.getAllVideos()
                checkFavoriteStatus()
            }
        }
    
    private func toggleFavorite() {
        if isVideoFavorited {
            // 如果已收藏，从默认收藏夹移除
            if let defaultFavorite = favoriteLists.first {
                if dbManager.removeVideoFromFavorite(videoId: video.id, favoriteId: defaultFavorite.id) {
                    successMessage = "已从收藏夹移除"
                    showSuccessAlert = true
                    isVideoFavorited = false
                }
            }
        } else {
            // 如果未收藏，添加到默认收藏夹
            if favoriteLists.isEmpty {
                let _ = dbManager.createFavoriteList(name: "我的收藏")
                favoriteLists = dbManager.getAllFavoriteLists()
            }
            if let defaultFavorite = favoriteLists.first {
                if dbManager.addVideoToFavorite(videoId: video.id, favoriteId: defaultFavorite.id) {
                    successMessage = "已添加到默认收藏夹"
                    showSuccessAlert = true
                    isVideoFavorited = true
                }
            }
        }
    }
    
    private func checkFavoriteStatus() {
        let allRelations = dbManager.getAllFavoriteLists().flatMap { list in
            dbManager.getVideosInFavoriteList(favoriteId: list.id).map { (list.id, $0.id) }
        }
        isVideoFavorited = allRelations.contains { $0.1 == video.id }
    }
}
