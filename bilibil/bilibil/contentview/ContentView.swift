import SwiftUI

struct ContentView: View {
    @State private var dbManager = DatabaseManager()
    @State private var favoriteLists: [(id: Int, name: String)] = []
    @State private var showingAddFavoriteList = false
    @State private var showingAddVideo = false
    @State private var newFavoriteListName = ""
    @State private var newVideoName = ""
    @State private var newVideoCover = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                // 标题
                                Text("我的收藏夹")
                                    .font(.headline)
                                    .padding(.horizontal)
                                    .padding(.top, 16)
                                    .padding(.bottom, 8)
                                
                                // 单列收藏夹列表
                                LazyVStack(spacing: 16) {
                                    ForEach(favoriteLists, id: \.id) { list in
                                        NavigationLink(destination: FavoriteDetailView(favoriteId: list.id, title: list.name, dbManager: dbManager)) {
                                            FavoriteListRow(favoriteId: list.id, title: list.name, dbManager: dbManager)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.top, 8)
                                .padding(.bottom, 30)
                            }
                        }
            .navigationTitle("收藏夹")
            .toolbar {
                // 第一个加号 - 添加视频
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddVideo = true }) {
                        Label("添加视频", systemImage: "plus")
                    }
                }
                
                // 第二个加号 - 添加收藏夹
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddFavoriteList = true }) {
                        Label("添加收藏夹", systemImage: "plus")
                    }
                }
            }
            // 添加视频的表单
            .sheet(isPresented: $showingAddVideo) {
                NavigationView {
                    Form {
                        TextField("视频名称", text: $newVideoName)
                        TextField("封面图标(SF Symbol)", text: $newVideoCover)
                    }
                    .navigationTitle("添加视频")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("取消") {
                                showingAddVideo = false
                                newVideoName = ""
                                newVideoCover = ""
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("添加") {
                                let _ = dbManager.addVideo(name: newVideoName, coverImage: newVideoCover)
                                showingAddVideo = false
                                newVideoName = ""
                                newVideoCover = ""
                            }
                            .disabled(newVideoName.isEmpty || newVideoCover.isEmpty)
                        }
                    }
                }
            }
            // 添加收藏夹的表单
            .sheet(isPresented: $showingAddFavoriteList) {
                NavigationView {
                    Form {
                        TextField("收藏夹名称", text: $newFavoriteListName)
                    }
                    .navigationTitle("新建收藏夹")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("取消") {
                                showingAddFavoriteList = false
                                newFavoriteListName = ""
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("创建") {
                                let _ = dbManager.createFavoriteList(name: newFavoriteListName)
                                favoriteLists = dbManager.getAllFavoriteLists()
                                showingAddFavoriteList = false
                                newFavoriteListName = ""
                            }
                            .disabled(newFavoriteListName.isEmpty)
                        }
                    }
                }
            }
            .onAppear {
                favoriteLists = dbManager.getAllFavoriteLists()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
