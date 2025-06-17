import SwiftUI
import Foundation

class VideoViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var videos: [Video] = []
    @Published var isShowingLoader: Bool = false
    @Published var dragOffset: CGFloat = 0
    
    private var page: Int = 0
    private let triggerThreshold: CGFloat = 60
    private let maxDragOffset: CGFloat = 100
    var databaseManager: DatabaseManager
    private var hasInitializedData = false
    
    // 初始化时传入数据库路径
    init(databasePath: String) {
        self.databaseManager = DatabaseManager(databasePath: databasePath)
        // 只在初始化时加载数据库中的视频
        self.videos = self.databaseManager.fetchVideos()
    }
    
    func handleScrollToBottom() {
        if !isLoading && !isShowingLoader {
            isShowingLoader = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if self.isShowingLoader {
                    self.loadMoreData()
                }
            }
        }
    }
    
    func handleScrollOffsetChange(_ offset: CGFloat) {
        guard !isLoading else { return }
        
        let newDragOffset = max(-offset - triggerThreshold, 0)
        dragOffset = min(newDragOffset, maxDragOffset)
        
        if newDragOffset > 0 && !isShowingLoader {
            isShowingLoader = true
        } else if newDragOffset <= 0 && isShowingLoader {
            isShowingLoader = false
        }
    }
    
    // MARK: - 网络请求与数据库操作
    func loadInitialData() {
        guard !hasInitializedData else { return }
        isLoading = true
        
        //let urlString = "https://apiv1.ssgpt.chat/videos"
        let urlString = "http://127.0.0.1:4523/m1/6447670-6145983-default/user/video/recommend"
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
     //   request.addValue("eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VySWQiOiIxODk2MDkzNTUwMCJ9.JV85gnurhGUCeK7D_DnG3NHznpABmSqtse3oNw1RDoc", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                self.isShowingLoader = false
                self.dragOffset = 0
                
                if let error = error {
                    print("请求失败: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("没有返回数据")
                    return
                }
                
                let decoder = JSONDecoder()
                if let response = try? decoder.decode(Response.self, from: data), let fetchedVideos = response.data {
                    // 只在初始化时保存到数据库
                    if !self.hasInitializedData {
                        self.databaseManager.insertVideos(fetchedVideos)
                        self.hasInitializedData = true
                    }
                    self.videos = fetchedVideos
                } else {
                    print("无法解析数据，使用模拟数据")
                }
            }
        }
        
        task.resume()
    }
    
    func loadMoreData() {
        if isLoading {
            return
        }
        
        isLoading = true
        isShowingLoader = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let currentCount = self.videos.count
            let copyCount = min(8, currentCount)
            
            if copyCount > 0 {
                let itemsToCopy = Array(self.videos.prefix(copyCount))
                let newItems = itemsToCopy.map { original in
                    Video(
                        id: UUID().uuidString,
                        isCoin: original.isCoin,
                        isCoinCount: original.isCoinCount,
                        isCollect: original.isCollect,
                        isCollectCount: original.isCollectCount,
                        isDislike: original.isDislike,
                        isLike: original.isLike,
                        isLikeCount: original.isLikeCount,
                        thumbPhoto: original.thumbPhoto,
                        title: original.title,
                        upData: original.upData
                    )
                }
                
                self.videos.append(contentsOf: newItems)
            }
            
            self.isLoading = false
            self.isShowingLoader = false
            self.dragOffset = 0
        }
    }
    
    func searchVideos(byTitle title: String) -> [Video] {
        if title.isEmpty {
            return videos
        }
        return videos.filter { $0.title.localizedCaseInsensitiveContains(title) }
    }
}

extension VideoViewModel {
    // 保存视频到本地数据库
    func saveVideoLocally(video: Video) {
        databaseManager.insertVideos([video])
        videos = databaseManager.fetchVideos()
    }
    
    // 删除本地视频
    func deleteLocalVideo(id: String) {
        databaseManager.deleteVideo(id: id)
        videos = databaseManager.fetchVideos()
    }
    
    // 清空本地视频
    func clearLocalVideos() {
        databaseManager.clearAllVideos()
        videos = []
    }
    
    // 刷新本地视频列表
    func refreshLocalVideos() {
        videos = databaseManager.fetchVideos()
    }
}

extension VideoViewModel {
    // 收藏/取消收藏视频
    func toggleVideoCollection(videoId: String, collectionId: String? = nil) -> Bool {
        let defaultCollectionId = getDefaultCollectionId()
        let targetCollectionId = collectionId ?? defaultCollectionId
        
        if databaseManager.isVideoInCollection(videoId: videoId, collectionId: targetCollectionId) {
            return databaseManager.removeVideoFromCollection(videoId: videoId, collectionId: targetCollectionId)
        } else {
            return databaseManager.addVideoToCollection(videoId: videoId, collectionId: targetCollectionId)
        }
    }
    
    
    // 获取收藏夹中的视频
    func getCollectionVideos(collectionId: String) -> [Video] {
        return databaseManager.getVideosInCollection(collectionId: collectionId)
    }
    
}

extension VideoViewModel {
    // 获取默认收藏夹ID
    func getDefaultCollectionId() -> String {
        let collections = databaseManager.getCollections()
        if let defaultCollection = collections.first(where: { $0.name == "默认收藏夹" }) {
            return defaultCollection.id
        }
        // 理论上不会执行到这里，因为初始化时已经创建了默认收藏夹
        databaseManager.addCollection(name: "默认收藏夹")
        return databaseManager.getCollections().first!.id
    }
    
    // 获取所有收藏夹（包含视频数量）
    func getCollections() -> [VideoCollection] {
        var collections = databaseManager.getCollections()
        // 为每个收藏夹添加视频数量
        for i in 0..<collections.count {
            collections[i].videoCount = databaseManager.getVideosInCollection(collectionId: collections[i].id).count
        }
        return collections
    }
    
    // 添加视频到默认收藏夹
    func addToDefaultCollection(videoId: String) -> Bool {
        let defaultCollectionId = getDefaultCollectionId()
        return databaseManager.addVideoToCollection(videoId: videoId, collectionId: defaultCollectionId)
    }
    
    // 从收藏夹移除视频
    func removeFromCollection(videoId: String, collectionId: String? = nil) -> Bool {
        let targetCollectionId = collectionId ?? getDefaultCollectionId()
        return databaseManager.removeVideoFromCollection(videoId: videoId, collectionId: targetCollectionId)
    }
    
    // 检查视频是否在收藏夹中
    func isVideoInCollection(videoId: String, collectionId: String? = nil) -> Bool {
        let targetCollectionId = collectionId ?? getDefaultCollectionId()
        return databaseManager.isVideoInCollection(videoId: videoId, collectionId: targetCollectionId)
    }
}

extension VideoViewModel {
    // 获取所有收藏夹（排除当前视频已存在的收藏夹）
    func getAvailableCollections(for videoId: String) -> [VideoCollection] {
        let allCollections = getCollections()
        return allCollections.filter { !databaseManager.isVideoInCollection(videoId: videoId, collectionId: $0.id) }
    }
    
    // 添加视频到指定收藏夹
    func addVideoToCollections(videoId: String, collectionIds: [String]) -> Bool {
        var success = true
        for collectionId in collectionIds {
            if !databaseManager.addVideoToCollection(videoId: videoId, collectionId: collectionId) {
                success = false
            }
        }
        return success
    }
}

extension VideoViewModel {
    // 获取视频所在的收藏夹
    func getCollectionsContaining(videoId: String) -> [VideoCollection] {
        let allCollections = getCollections()
        return allCollections.filter { databaseManager.isVideoInCollection(videoId: videoId, collectionId: $0.id) }
    }
    
    // 从所有收藏夹中移除视频
    func removeVideoFromAllCollections(videoId: String) -> Bool {
        let collections = getCollectionsContaining(videoId: videoId)
        var success = true
        for collection in collections {
            if !databaseManager.removeVideoFromCollection(videoId: videoId, collectionId: collection.id) {
                success = false
            }
        }
        return success
    }
}

