//
//  RecommendView.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/5/30.
//

import SwiftUI

struct RecommendView: View {
    @StateObject private var viewModel = VideoViewModel(
        databasePath: NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        ).first! + "/videos.db"
    )
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        
            VStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(viewModel.videos) { video in
                            VideoCellView(video: video)
                                .onAppear {
                                    print("视频id: \(video.id), 收藏: \(video.isCollect), 点赞: \(video.isLike)")
                                }
                        }
                    }
                    .padding()
                    
                    // 底部加载视图
                    if viewModel.isShowingLoader || viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                            .transition(.opacity)
                    } else {
                        // 底部空间，用于检测滚动到底部
                        GeometryReader { geometry in
                            Color.clear
                                .frame(height: 1)
                                .onAppear {
                                    // 当这个视图出现时，表示用户滚动到了底部
                                    viewModel.handleScrollToBottom()
                                }
                        }
                        .frame(height: 1)
                    }
                }
                .background(
                    // 用于检测拖动偏移量
                    GeometryReader { geometry in
                        Color.clear
                            .preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: geometry.frame(in: .named("scrollView")).origin.y
                            )
                    }
                )
                .coordinateSpace(name: "scrollView")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    // 处理滚动偏移量变化
                    viewModel.handleScrollOffsetChange(value)
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                viewModel.loadInitialData()
            }
        }
    
}

#Preview {
    RecommendView()
}
