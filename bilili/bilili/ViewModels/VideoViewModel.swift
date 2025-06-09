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
    private var databaseManager: DatabaseManager
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
        
        let urlString = "http://127.0.0.1:4523/m1/6447670-6145983-default/user/video/recommend?page=0&pagesize=8"
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.addValue("eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VySWQiOiIxODk2MDkzNTUwMCJ9.JV85gnurhGUCeK7D_DnG3NHznpABmSqtse3oNw1RDoc", forHTTPHeaderField: "Authorization")
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
