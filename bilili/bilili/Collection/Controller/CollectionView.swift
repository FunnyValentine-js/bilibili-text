//
//  CollectionView.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/5/23.
//

import SwiftUI

//struct VideoRowItemView: View {
//    let video: Video
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                // 视频缩略图
//                AsyncImage(url: URL(string: video.thumbPhoto)) { phase in
//                    if let image = phase.image {
//                        image.resizable()
//                            .aspectRatio(contentMode: .fill)
//                    } else if phase.error != nil {
//                        Color.gray
//                    } else {
//                        ProgressView()
//                    }
//                }
//                .frame(width: 120, height: 80)
//                .cornerRadius(4)
//                
//                VStack(alignment: .leading, spacing: 4) {
//                    // 视频标题
//                    Text(video.title)
//                        .font(.subheadline)
//                        .lineLimit(2)
//                    
//                    // UP主信息
//                    HStack {
//                        AsyncImage(url: URL(string: video.upData.avator)) { phase in
//                            if let image = phase.image {
//                                image.resizable()
//                                    .aspectRatio(contentMode: .fill)
//                            } else if phase.error != nil {
//                                Color.gray
//                            } else {
//                                ProgressView()
//                            }
//                        }
//                        .frame(width: 20, height: 20)
//                        .clipShape(Circle())
//                        
//                        Text(video.upData.name)
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                    }
//                    
//                    // 互动数据
//                    HStack(spacing: 16) {
//                        Label("\(video.isLikeCount)", systemImage: "hand.thumbsup")
//                            .font(.caption2)
//                        Label("\(video.isCoinCount)", systemImage: "dollarsign.circle")
//                            .font(.caption2)
//                    }
//                    .foregroundColor(.gray)
//                }
//            }
//        }
//        .padding(.vertical, 8)
//    }
//}

struct CollectionView: View {
    @EnvironmentObject var viewModel: VideoViewModel
    @State private var showingNewCollectionSheet = false
    @State private var newCollectionName = ""
    @State private var collections: [VideoCollection] = []
    
    var body: some View {
        NavigationView {
            List {
                // 确保默认收藏夹始终显示在最前面
                ForEach(collections.sorted { $0.name == "默认收藏夹" && $1.name != "默认收藏夹" }) { collection in
                    NavigationLink(destination: CollectionDetailView(collection: collection)) {
                        HStack {
                            Image(systemName: collection.name == "默认收藏夹" ? "star.fill" : "folder.fill")
                                .foregroundColor(collection.name == "默认收藏夹" ? .yellow : .blue)
                            Text(collection.name)
                            Spacer()
                            Text("\(collection.videoCount)")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: deleteCollections)
            }
            .navigationTitle("我的收藏夹")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewCollectionSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewCollectionSheet) {
                NewCollectionView(isPresented: $showingNewCollectionSheet)
            }
            .onAppear {
                refreshCollections()
            }
        }
    }
    
    private func refreshCollections() {
        collections = viewModel.getCollections()
    }
    
    private func deleteCollections(at offsets: IndexSet) {
        for index in offsets {
            let collection = collections[index]
            // 不能删除默认收藏夹
            if collection.name != "默认收藏夹" {
                viewModel.databaseManager.deleteCollection(collectionId: collection.id)
            }
        }
        refreshCollections()
    }
}





