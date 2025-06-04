/**
 * @file ContentView.swift
 * @description 我的页面，展示收藏夹列表及添加功能。
 * @author SOSD_M1_2
 * @date 2025/4/25
 */
import SwiftUI

/**
 * @struct ContentView
 * @description 我的页面主视图，展示收藏夹及添加入口。
 * @property {DatabaseManager} dbManager 数据库管理器。
 * @property {Array} favoriteLists 收藏夹列表。
 * @property {Bool} showingAddFavoriteList 是否显示添加收藏夹弹窗。
 * @property {Bool} showingAddVideo 是否显示添加视频弹窗。
 * @property {String} newFavoriteListName 新建收藏夹名称。
 * @property {String} newVideoName 新建视频名称。
 * @property {String} newVideoCover 新建视频封面。
 * @property {Bool} showLoginAlert 是否显示登录未实现提示。
 * @property {Bool} showLoginSheet 是否显示登录页面。
 */
struct ContentView: View {
    @State private var dbManager = DatabaseManager()
    @State private var favoriteLists: [(id: Int, name: String)] = []
    @State private var showingAddFavoriteList = false
    @State private var showingAddVideo = false
    @State private var newFavoriteListName = ""
    @State private var newVideoName = ""
    @State private var newVideoCover = ""
    @State private var showLoginAlert = false
    @State private var showLoginSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    /**
                     * 登录按钮。
                     */
                    Button(action: {
                        // 弹出登录页面
                        showLoginSheet = true
                    }) {
                        Text("登录")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .padding(.top, 16)
                    }
                    .sheet(isPresented: $showLoginSheet) {
                        LoginView()
                    }
                    
                    /**
                     * 页面标题。
                     */
                    Text("我的收藏夹")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    
                    /**
                     * 收藏夹列表，点击可进入详情。
                     */
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
            .navigationTitle("个人中心")
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
            /**
             * 添加视频弹窗表单。
             */
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
            /**
             * 添加收藏夹弹窗表单。
             */
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

/**
 * @description ContentView 预览。
 */
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
