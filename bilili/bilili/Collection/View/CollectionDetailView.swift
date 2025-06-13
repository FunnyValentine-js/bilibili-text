//
//  CollectionDetailView.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/6/10.
//

import SwiftUI

/**
 * 收藏夹详情视图，展示所有已收藏的视频。
 * - 每个视频以卡片样式展示，一行一列。
 * - 点击卡片跳转到视频详情页。
 * - 每次进入页面实时刷新收藏夹下的视频。
 */
struct CollectionDetailView: View {
    /// 视频视图模型，负责数据获取与操作
    @EnvironmentObject var viewModel: VideoViewModel
    /// 当前收藏夹对象
    let collection: VideoCollection
    /// 当前收藏夹下的视频列表
    @State private var videos: [Video] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(videos) { video in
                    NavigationLink(destination: VideoDetailView(
                        video: video,
                        isFollowing: video.upData.isFollow,
                        isLiking: video.isLike,
                        isDisliking: video.isDislike,
                        isCoining: video.isCoin,
                        isCollectwing: video.isCollect
                    )) {
                        VideoCardView(video: video)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .navigationTitle(collection.name)
        .onAppear {
            refreshVideos()
        }
    }
    
    /**
     * 刷新当前收藏夹下的视频列表
     */
    private func refreshVideos() {
        videos = viewModel.databaseManager.getAllCollectedVideos()
    }
}

/**
 * 单个视频卡片视图，参考首页样式，一行一列
 * @param video 视频对象
 */
struct VideoCardView: View {
    let video: Video
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 封面图
            AsyncImage(url: URL(string: video.thumbPhoto)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 120, height: 80)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 80)
                        .clipped()
                        .cornerRadius(10)
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .frame(width: 120, height: 80)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                @unknown default:
                    EmptyView()
                }
            }
            // 右侧信息
            VStack(alignment: .leading, spacing: 6) {
                Text(video.title)
                    .font(.headline)
                    .foregroundColor(.pink)
                    .lineLimit(2)
                Text(video.upData.name)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                if !video.title.isEmpty {
                    Text(video.title)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}
