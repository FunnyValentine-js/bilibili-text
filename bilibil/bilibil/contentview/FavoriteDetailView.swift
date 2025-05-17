//
//  FavoriteDetailView.swift
//  bilibil
//
//  Created by SOSD_M1_2 on 2025/4/25.
//

import SwiftUI

struct FavoriteDetailView: View {
    let favoriteId: Int
    let title: String
    let dbManager: DatabaseManager
    
    @State private var videos: [(id: Int, name: String, coverImage: String)] = []
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    @State private var videoToDelete: Int?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 顶部收藏夹名称
                HStack {
                    Text(title)
                        .font(.title)
                        .bold()
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // 分割线
                Divider()
                    .padding(.horizontal)
                
                // 视频列表
                LazyVStack(spacing: 16) {
                    ForEach(videos, id: \.id) { video in
                        HStack {
                            // 视频卡片
                            NavigationLink(destination: VideoDetailView(video: video)) {
                                DetailVideoCard(
                                    title: video.name,
                                    author: "UP主 \(video.id)",
                                    views: "\(Int.random(in: 1000...10000))观看",
                                    coverImage: video.coverImage
                                )
                                .padding(.horizontal)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // 编辑模式下显示删除按钮
                            if isEditing {
                                Button(action: {
                                    videoToDelete = video.id
                                    showingDeleteAlert = true
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .padding(.trailing, 16)
                            }
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "完成" : "编辑")
                }
            }
        }
        .alert("确认删除", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                if let videoId = videoToDelete {
                    deleteVideo(videoId: videoId)
                }
            }
        } message: {
            Text("确定要从收藏夹中删除这个视频吗？")
        }
        .onAppear {
            refreshVideos()
        }
    }
    
    private func refreshVideos() {
        videos = dbManager.getVideosInFavoriteList(favoriteId: favoriteId)
    }
    
    private func deleteVideo(videoId: Int) {
        if dbManager.removeVideoFromFavorite(videoId: videoId, favoriteId: favoriteId) {
            refreshVideos()
        }
    }
}

