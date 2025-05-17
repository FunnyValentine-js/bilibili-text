//
//  FavoriteSelectionView.swift
//  bilibil
//
//  Created by SOSD_M1_2 on 2025/4/25.
//

import SwiftUI

struct FavoriteSelectionView: View {
    let videoId: Int
    @State var favoriteLists: [(id: Int, name: String)]
    let isVideoFavorited: Bool
    let dbManager: DatabaseManager
    let onComplete: (String) -> Void
    
    @State private var newFavoriteName = ""
    @State private var showingAddFavorite = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("选择收藏夹")) {
                    ForEach(favoriteLists, id: \.id) { list in
                        HStack {
                            Button(action: {
                                toggleVideoInFavorite(listId: list.id)
                            }) {
                                HStack {
                                    Text(list.name)
                                    Spacer()
                                    if isVideoInFavorite(listId: list.id) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            if isVideoInFavorite(listId: list.id) {
                                Button(action: {
                                    removeFromFavorite(listId: list.id)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                    }
                    
                    Button(action: {
                        showingAddFavorite = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                            Text("新建收藏夹")
                        }
                    }
                }
            }
            .navigationTitle("管理收藏")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("完成") {
                        onComplete("收藏已更新")
                    }
                }
            }
            .sheet(isPresented: $showingAddFavorite) {
                NavigationView {
                    Form {
                        TextField("收藏夹名称", text: $newFavoriteName)
                    }
                    .navigationTitle("新建收藏夹")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("取消") {
                                showingAddFavorite = false
                                newFavoriteName = ""
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("创建") {
                                createNewFavorite()
                            }
                            .disabled(newFavoriteName.isEmpty)
                        }
                    }
                }
            }
        }
    }
    
    private func isVideoInFavorite(listId: Int) -> Bool {
        return dbManager.getVideosInFavoriteList(favoriteId: listId).contains { $0.id == videoId }
    }
    
    private func toggleVideoInFavorite(listId: Int) {
        if isVideoInFavorite(listId: listId) {
            removeFromFavorite(listId: listId)
        } else {
            addToFavorite(listId: listId)
        }
    }
    
    private func addToFavorite(listId: Int) {
        if dbManager.addVideoToFavorite(videoId: videoId, favoriteId: listId) {
            if let listName = favoriteLists.first(where: { $0.id == listId })?.name {
                onComplete("已添加到收藏夹: \(listName)")
            }
        } else {
            onComplete("添加失败，请重试")
        }
    }
    
    private func removeFromFavorite(listId: Int) {
        if dbManager.removeVideoFromFavorite(videoId: videoId, favoriteId: listId) {
            if let listName = favoriteLists.first(where: { $0.id == listId })?.name {
                onComplete("已从收藏夹移除: \(listName)")
            }
        } else {
            onComplete("移除失败，请重试")
        }
    }
    
    private func createNewFavorite() {
        let newId = dbManager.createFavoriteList(name: newFavoriteName)
        if newId != -1 {
            favoriteLists = dbManager.getAllFavoriteLists()
            showingAddFavorite = false
            newFavoriteName = ""
            // 自动将当前视频添加到新收藏夹
            addToFavorite(listId: newId)
        } else {
            onComplete("创建收藏夹失败")
        }
    }
}

