import SQLite3
import Foundation

class DatabaseManager {
    var db: OpaquePointer?
    
    init(databasePath: String) {
        if sqlite3_open(databasePath, &db) != SQLITE_OK {
            print("无法打开数据库")
        } else {
            createTable()
            setupDefaultCollection() // 添加这行
        }
    }
    
    private func createTable() {
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS Videos (
            id TEXT PRIMARY KEY,
            isCoin INTEGER,
            isCoinCount INTEGER,
            isCollect INTEGER,
            isCollectCount INTEGER,
            isDislike INTEGER,
            isLike INTEGER,
            isLikeCount INTEGER,
            thumbPhoto TEXT,
            title TEXT,
            upDataAvator TEXT,
            upDataFans INTEGER,
            upDataIsFollow INTEGER,
            upDataName TEXT,
            upDataUid TEXT,
            upDataVideoCount INTEGER
        );
        """
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, createTableQuery, -1, &statement, nil) != SQLITE_OK {
            print("创建表格失败: \(String(cString: sqlite3_errmsg(db)))")
        } else {
            if sqlite3_step(statement) != SQLITE_DONE {
                print("创建表格失败: \(String(cString: sqlite3_errmsg(db)))")
            }
        }
        
        sqlite3_finalize(statement)
    }
    
    // 修改为批量插入方法
    func insertVideos(_ videos: [Video]) {
        // 开始事务
        guard sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil) == SQLITE_OK else {
            print("开始事务失败")
            return
        }
        
        let insertQuery = """
        INSERT INTO Videos (id, isCoin, isCoinCount, isCollect, isCollectCount, isDislike, isLike, isLikeCount, thumbPhoto, title, upDataAvator, upDataFans, upDataIsFollow, upDataName, upDataUid, upDataVideoCount)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) != SQLITE_OK {
            print("插入数据失败: \(String(cString: sqlite3_errmsg(db)))")
            return
        }
        
        for video in videos {
            // 绑定参数
            sqlite3_bind_text(statement, 1, (video.id as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, video.isCoin ? 1 : 0)
            sqlite3_bind_int(statement, 3, Int32(video.isCoinCount))
            sqlite3_bind_int(statement, 4, video.isCollect ? 1 : 0)
            sqlite3_bind_int(statement, 5, Int32(video.isCollectCount))
            sqlite3_bind_int(statement, 6, video.isDislike ? 1 : 0)
            sqlite3_bind_int(statement, 7, video.isLike ? 1 : 0)
            sqlite3_bind_int(statement, 8, Int32(video.isLikeCount))
            sqlite3_bind_text(statement, 9, (video.thumbPhoto as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 10, (video.title as NSString).utf8String, -1, nil)
            
            // UpData字段
            sqlite3_bind_text(statement, 11, (video.upData.avator as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 12, Int32(video.upData.fans))
            sqlite3_bind_int(statement, 13, video.upData.isFollow ? 1 : 0)
            sqlite3_bind_text(statement, 14, (video.upData.name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 15, (video.upData.uid as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 16, Int32(video.upData.videoCount))
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("插入数据失败: \(String(cString: sqlite3_errmsg(db)))")
            }
            
            // 重置statement以便下次使用
            sqlite3_reset(statement)
        }
        
        sqlite3_finalize(statement)
        
        // 提交事务
        guard sqlite3_exec(db, "COMMIT TRANSACTION", nil, nil, nil) == SQLITE_OK else {
            print("提交事务失败")
            return
        }
    }
    
    func fetchVideos() -> [Video] {
        let fetchQuery = "SELECT * FROM Videos;"
        var statement: OpaquePointer?
        var videos: [Video] = []
        
        if sqlite3_prepare_v2(db, fetchQuery, -1, &statement, nil) != SQLITE_OK {
            print("无法准备查询语句: \(String(cString: sqlite3_errmsg(db)))")
            return videos
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let id = String(cString: sqlite3_column_text(statement, 0))
            let isCoin = sqlite3_column_int(statement, 1) != 0
            let isCoinCount = Int(sqlite3_column_int(statement, 2))
            let isCollect = sqlite3_column_int(statement, 3) != 0
            let isCollectCount = Int(sqlite3_column_int(statement, 4))
            let isDislike = sqlite3_column_int(statement, 5) != 0
            let isLike = sqlite3_column_int(statement, 6) != 0
            let isLikeCount = Int(sqlite3_column_int(statement, 7))
            let thumbPhoto = String(cString: sqlite3_column_text(statement, 8))
            let title = String(cString: sqlite3_column_text(statement, 9))
            
            // UpData字段
            let upDataAvator = String(cString: sqlite3_column_text(statement, 10))
            let upDataFans = Int(sqlite3_column_int(statement, 11))
            let upDataIsFollow = sqlite3_column_int(statement, 12) != 0
            let upDataName = String(cString: sqlite3_column_text(statement, 13))
            let upDataUid = String(cString: sqlite3_column_text(statement, 14))
            let upDataVideoCount = Int(sqlite3_column_int(statement, 15))
            
            let upData = UpData(avator: upDataAvator, fans: upDataFans, isFollow: upDataIsFollow, name: upDataName, uid: upDataUid, videoCount: upDataVideoCount)
            
            let video = Video(id: id, isCoin: isCoin, isCoinCount: isCoinCount, isCollect: isCollect, isCollectCount: isCollectCount, isDislike: isDislike, isLike: isLike, isLikeCount: isLikeCount, thumbPhoto: thumbPhoto, title: title, upData: upData)
            videos.append(video)
        }
        
        sqlite3_finalize(statement)
        return videos
    }
    
    deinit {
        sqlite3_close(db)
    }
}

extension DatabaseManager {
    // 初始化时创建默认收藏夹
    private func setupDefaultCollection() {
        createCollectionsTable()
        
        // 检查默认收藏夹是否存在
        let checkQuery = "SELECT COUNT(*) FROM Collections WHERE name = '默认收藏夹';"
        var statement: OpaquePointer?
        var count: Int32 = 0
        
        if sqlite3_prepare_v2(db, checkQuery, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                count = sqlite3_column_int(statement, 0)
            }
        }
        sqlite3_finalize(statement)
        
        // 如果不存在，则创建默认收藏夹
        if count == 0 {
            addCollection(name: "默认收藏夹")
        }
    }
    
    
}

extension DatabaseManager {
    // 检查视频是否已存在
    func videoExists(id: String) -> Bool {
        let query = "SELECT COUNT(*) FROM Videos WHERE id = ?;"
        var statement: OpaquePointer?
        var exists = false
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (id as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                exists = sqlite3_column_int(statement, 0) > 0
            }
        }
        
        sqlite3_finalize(statement)
        return exists
    }
    
    // 删除单个视频
    func deleteVideo(id: String) {
        let query = "DELETE FROM Videos WHERE id = ?;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (id as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("删除视频失败: \(String(cString: sqlite3_errmsg(db)))")
            }
        }
        
        sqlite3_finalize(statement)
    }
    
    // 清空所有视频
    func clearAllVideos() {
        let query = "DELETE FROM Videos;"
        
        if sqlite3_exec(db, query, nil, nil, nil) != SQLITE_OK {
            print("清空视频失败: \(String(cString: sqlite3_errmsg(db)))")
        }
    }
}

extension DatabaseManager {
    // 创建收藏夹表
     func createCollectionsTable() {
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS Collections (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            createdAt TEXT NOT NULL
        );
        
        CREATE TABLE IF NOT EXISTS CollectionItems (
            id TEXT PRIMARY KEY,
            collectionId TEXT NOT NULL,
            videoId TEXT NOT NULL,
            addedAt TEXT NOT NULL,
            FOREIGN KEY (collectionId) REFERENCES Collections(id),
            FOREIGN KEY (videoId) REFERENCES Videos(id)
        );
        """
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, createTableQuery, -1, &statement, nil) != SQLITE_OK {
            print("创建收藏夹表格失败: \(String(cString: sqlite3_errmsg(db)))")
        } else {
            if sqlite3_step(statement) != SQLITE_DONE {
                print("创建收藏夹表格失败: \(String(cString: sqlite3_errmsg(db)))")
            }
        }
        sqlite3_finalize(statement)
    }
    
    // 初始化时调用
     func setupCollections() {
        createCollectionsTable()
        // 确保有一个默认收藏夹
        if getCollections().isEmpty {
            addCollection(name: "默认收藏夹")
        }
    }
    
    // 添加收藏夹
    func addCollection(name: String) {
        let query = "INSERT INTO Collections (id, name, createdAt) VALUES (?, ?, ?);"
        var statement: OpaquePointer?
        
        let id = UUID().uuidString
        let createdAt = ISO8601DateFormatter().string(from: Date())
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (id as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (createdAt as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("添加收藏夹失败: \(String(cString: sqlite3_errmsg(db)))")
            }
        }
        sqlite3_finalize(statement)
    }
    
    // 获取所有收藏夹
    func getCollections() -> [VideoCollection] {
        let query = "SELECT * FROM Collections ORDER BY createdAt DESC;"
        var statement: OpaquePointer?
        var collections: [VideoCollection] = []
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(statement, 0))
                let name = String(cString: sqlite3_column_text(statement, 1))
                let createdAt = String(cString: sqlite3_column_text(statement, 2))
                
                if let date = ISO8601DateFormatter().date(from: createdAt) {
                    collections.append(VideoCollection(id: id, name: name, createdAt: date))
                }
            }
        }
        sqlite3_finalize(statement)
        return collections
    }
    
    // 添加视频到收藏夹
    func addVideoToCollection(videoId: String, collectionId: String) -> Bool {
        let query = "INSERT INTO CollectionItems (id, collectionId, videoId, addedAt) VALUES (?, ?, ?, ?);"
        var statement: OpaquePointer?
        var success = false
        
        let id = UUID().uuidString
        let addedAt = ISO8601DateFormatter().string(from: Date())
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (id as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (collectionId as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (videoId as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (addedAt as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                success = true
            } else {
                print("添加视频到收藏夹失败: \(String(cString: sqlite3_errmsg(db)))")
            }
        }
        sqlite3_finalize(statement)
        return success
    }
    
    // 从收藏夹移除视频
    func removeVideoFromCollection(videoId: String, collectionId: String) -> Bool {
        let query = "DELETE FROM CollectionItems WHERE videoId = ? AND collectionId = ?;"
        var statement: OpaquePointer?
        var success = false
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (videoId as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (collectionId as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                success = true
            } else {
                print("从收藏夹移除视频失败: \(String(cString: sqlite3_errmsg(db)))")
            }
        }
        sqlite3_finalize(statement)
        return success
    }
    
    // 检查视频是否在收藏夹中
    func isVideoInCollection(videoId: String, collectionId: String) -> Bool {
        let query = "SELECT COUNT(*) FROM CollectionItems WHERE videoId = ? AND collectionId = ?;"
        var statement: OpaquePointer?
        var exists = false
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (videoId as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (collectionId as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                exists = sqlite3_column_int(statement, 0) > 0
            }
        }
        sqlite3_finalize(statement)
        return exists
    }
    
    // 获取收藏夹中的视频
    func getVideosInCollection(collectionId: String) -> [Video] {
        let query = """
        SELECT v.* FROM Videos v
        JOIN CollectionItems ci ON v.id = ci.videoId
        WHERE ci.collectionId = ?
        ORDER BY ci.addedAt DESC;
        """
        
        var statement: OpaquePointer?
        var videos: [Video] = []
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (collectionId as NSString).utf8String, -1, nil)
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(statement, 0))
                let isCoin = sqlite3_column_int(statement, 1) != 0
                let isCoinCount = Int(sqlite3_column_int(statement, 2))
                let isCollect = sqlite3_column_int(statement, 3) != 0
                let isCollectCount = Int(sqlite3_column_int(statement, 4))
                let isDislike = sqlite3_column_int(statement, 5) != 0
                let isLike = sqlite3_column_int(statement, 6) != 0
                let isLikeCount = Int(sqlite3_column_int(statement, 7))
                let thumbPhoto = String(cString: sqlite3_column_text(statement, 8))
                let title = String(cString: sqlite3_column_text(statement, 9))
                
                // UpData字段
                let upDataAvator = String(cString: sqlite3_column_text(statement, 10))
                let upDataFans = Int(sqlite3_column_int(statement, 11))
                let upDataIsFollow = sqlite3_column_int(statement, 12) != 0
                let upDataName = String(cString: sqlite3_column_text(statement, 13))
                let upDataUid = String(cString: sqlite3_column_text(statement, 14))
                let upDataVideoCount = Int(sqlite3_column_int(statement, 15))
                
                let upData = UpData(
                    avator: upDataAvator,
                    fans: upDataFans,
                    isFollow: upDataIsFollow,
                    name: upDataName,
                    uid: upDataUid,
                    videoCount: upDataVideoCount
                )
                
                let video = Video(
                    id: id,
                    isCoin: isCoin,
                    isCoinCount: isCoinCount,
                    isCollect: isCollect,
                    isCollectCount: isCollectCount,
                    isDislike: isDislike,
                    isLike: isLike,
                    isLikeCount: isLikeCount,
                    thumbPhoto: thumbPhoto,
                    title: title,
                    upData: upData
                )
                videos.append(video)
            }
        }
        sqlite3_finalize(statement)
        return videos
    }
}

extension DatabaseManager {
    // 删除收藏夹
    func deleteCollection(collectionId: String) -> Bool {
        let deleteItemsQuery = "DELETE FROM CollectionItems WHERE collectionId = ?;"
        let deleteCollectionQuery = "DELETE FROM Collections WHERE id = ?;"
        var success = false
        
        // 开始事务
        guard sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil) == SQLITE_OK else {
            print("开始事务失败")
            return false
        }
        
        // 先删除收藏夹中的项目
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, deleteItemsQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (collectionId as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                success = true
            } else {
                print("删除收藏夹项目失败: \(String(cString: sqlite3_errmsg(db)))")
                success = false
            }
        }
        sqlite3_finalize(statement)
        
        // 如果删除项目成功，再删除收藏夹
        if success {
            if sqlite3_prepare_v2(db, deleteCollectionQuery, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_text(statement, 1, (collectionId as NSString).utf8String, -1, nil)
                
                if sqlite3_step(statement) != SQLITE_DONE {
                    print("删除收藏夹失败: \(String(cString: sqlite3_errmsg(db)))")
                    success = false
                }
            }
            sqlite3_finalize(statement)
        }
        
        // 提交或回滚事务
        if success {
            guard sqlite3_exec(db, "COMMIT TRANSACTION", nil, nil, nil) == SQLITE_OK else {
                print("提交事务失败")
                return false
            }
        } else {
            guard sqlite3_exec(db, "ROLLBACK TRANSACTION", nil, nil, nil) == SQLITE_OK else {
                print("回滚事务失败")
                return false
            }
        }
        
        return success
    }
}
