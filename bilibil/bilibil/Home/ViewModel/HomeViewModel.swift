import Foundation
import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    // 数据库管理器
    let dbManager = DatabaseManager.shared
    // 所有视频
    @Published var allVideos: [(id: Int, name: String, coverImage: String)] = []
    // 当前展示的视频（分页）
    @Published var displayedVideos: [(id: Int, name: String, coverImage: String)] = []
    // 当前选中的分区Tab
    @Published var selectedTab = 1
    // 拖拽偏移量
    @Published var offset: CGFloat = 0
    // 当前分页页码
    @Published var currentPage = 0
    // 是否还有更多视频
    @Published var hasMoreVideos = true
    // 每页视频数量
    let pageSize = 10
    // Tab配置
    let tabs = [
        (id: 0, name: "直播"),
        (id: 1, name: "推荐"),
        (id: 2, name: "热门"),
        (id: 3, name: "动画"),
        (id: 4, name: "影视")
    ]
    // 示例视频
    let sampleVideos = [
        (name: "Swift基础语法详解", coverImage: "swift"),
        (name: "UIKit框架实战", coverImage: "uikit"),
        (name: "Firebase后端集成", coverImage: "flame"),
        (name: "Apple Pay集成教程", coverImage: "apple.pay"),
        (name: "HealthKit数据处理", coverImage: "heart.fill"),
        (name: "地图应用开发", coverImage: "map"),
        (name: "游戏开发基础", coverImage: "gamecontroller"),
        (name: "自动化测试技巧", coverImage: "checkmark.circle"),
        (name: "SwiftUI动画特效", coverImage: "sparkles"),
        (name: "App性能优化", coverImage: "speedometer"),
        (name: "多语言支持实现", coverImage: "globe"),
        (name: "蓝牙设备连接", coverImage: "wave.3.right.circle"),
        (name: "PDF文件处理", coverImage: "doc.text"),
        (name: "图像识别技术", coverImage: "eye"),
        (name: "推送通知设置", coverImage: "bell"),
        (name: "自定义UI组件", coverImage: "square.and.pencil"),
        (name: "网络请求优化", coverImage: "network"),
        (name: "iOS隐私保护", coverImage: "lock.shield"),
        (name: "应用内购买实现", coverImage: "cart"),
        (name: "WatchKit开发入门", coverImage: "applewatch")
    ]
    
    // MARK: - 生命周期
    func onAppear() {
        if dbManager.getAllVideos().isEmpty {
            addSampleVideos()
        }
        refreshVideos()
    }
    // MARK: - 分区Tab滑动
    func handleSwipe(_ value: DragGesture.Value) {
        withAnimation {
            if value.translation.width < -100 && selectedTab < tabs.count - 1 {
                selectedTab += 1
            } else if value.translation.width > 100 && selectedTab > 0 {
                selectedTab -= 1
            }
            offset = 0
        }
    }
    // MARK: - 添加示例视频
    private func addSampleVideos() {
        for video in sampleVideos {
            _ = dbManager.addVideo(name: video.name, coverImage: video.coverImage)
        }
    }
    // MARK: - 刷新视频
    func refreshVideos() {
        allVideos = dbManager.getAllVideos()
        currentPage = 0
        hasMoreVideos = allVideos.count > pageSize
        displayedVideos = Array(allVideos.prefix(pageSize))
    }
    // MARK: - 分页加载更多
    func loadMoreVideos() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let nextPage = self.currentPage + 1
            let startIndex = nextPage * self.pageSize
            guard startIndex < self.allVideos.count else {
                self.hasMoreVideos = false
                return
            }
            let endIndex = min(startIndex + self.pageSize, self.allVideos.count)
            let newVideos = Array(self.allVideos[startIndex..<endIndex])
            self.displayedVideos.append(contentsOf: newVideos)
            self.currentPage = nextPage
            self.hasMoreVideos = endIndex < self.allVideos.count
        }
    }
} 