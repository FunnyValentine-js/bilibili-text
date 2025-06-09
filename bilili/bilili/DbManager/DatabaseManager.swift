import SQLite3
import Foundation

class DatabaseManager {
    private var db: OpaquePointer?
    
    init(databasePath: String) {
        if sqlite3_open(databasePath, &db) != SQLITE_OK {
            print("无法打开数据库")
        } else {
            createTable()
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
    
    /// 新增
    private func createFavoriteTable() {
        let createFavoritesTableQuery = """
        CREATE TABLE IF NOT EXISTS Favorites (
            id TEXT PRIMARY KEY,
            name TEXT
        );
        """
        
        let createFavoriteVideosTableQuery = """
        CREATE TABLE IF NOT EXISTS FavoriteVideos (
            favoriteId TEXT,
            videoId TEXT,
            PRIMARY KEY (favoriteId, videoId),
            FOREIGN KEY (favoriteId) REFERENCES Favorites(id),
            FOREIGN KEY (videoId) REFERENCES Videos(id)
        );
        """
        
        var statement: OpaquePointer?
        
        // 创建 Favorites 表
        if sqlite3_prepare_v2(db, createFavoritesTableQuery, -1, &statement, nil) != SQLITE_OK {
            print("创建Favorites表失败: \(String(cString: sqlite3_errmsg(db)))")
        } else {
            if sqlite3_step(statement) != SQLITE_DONE {
                print("创建Favorites表失败: \(String(cString: sqlite3_errmsg(db)))")
            }
        }
        
        // 创建 FavoriteVideos 表
        if sqlite3_prepare_v2(db, createFavoriteVideosTableQuery, -1, &statement, nil) != SQLITE_OK {
            print("创建FavoriteVideos表失败: \(String(cString: sqlite3_errmsg(db)))")
        } else {
            if sqlite3_step(statement) != SQLITE_DONE {
                print("创建FavoriteVideos表失败: \(String(cString: sqlite3_errmsg(db)))")
            }
        }
        
        sqlite3_finalize(statement)
    }

    func addFavorite(name: String) {
        let insertFavoriteQuery = """
        INSERT INTO Favorites (id, name)
        VALUES (?, ?);
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertFavoriteQuery, -1, &statement, nil) != SQLITE_OK {
            print("添加收藏夹失败: \(String(cString: sqlite3_errmsg(db)))")
            return
        }
        
        let favoriteId = UUID().uuidString
        sqlite3_bind_text(statement, 1, favoriteId, -1, nil)
        sqlite3_bind_text(statement, 2, name, -1, nil)
        
        if sqlite3_step(statement) != SQLITE_DONE {
            print("添加收藏夹失败: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(statement)
    }

    func deleteFavorite(id: String) {
        let deleteFavoriteQuery = """
        DELETE FROM Favorites WHERE id = ?;
        DELETE FROM FavoriteVideos WHERE favoriteId = ?;
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteFavoriteQuery, -1, &statement, nil) != SQLITE_OK {
            print("删除收藏夹失败: \(String(cString: sqlite3_errmsg(db)))")
            return
        }
        
        sqlite3_bind_text(statement, 1, id, -1, nil)
        sqlite3_bind_text(statement, 2, id, -1, nil)
        
        if sqlite3_step(statement) != SQLITE_DONE {
            print("删除收藏夹失败: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(statement)
    }

    func addVideoToFavorite(videoId: String, favoriteId: String) {
        let insertFavoriteVideoQuery = """
        INSERT INTO FavoriteVideos (favoriteId, videoId)
        VALUES (?, ?);
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertFavoriteVideoQuery, -1, &statement, nil) != SQLITE_OK {
            print("将视频添加到收藏夹失败: \(String(cString: sqlite3_errmsg(db)))")
            return
        }
        
        sqlite3_bind_text(statement, 1, favoriteId, -1, nil)
        sqlite3_bind_text(statement, 2, videoId, -1, nil)
        
        if sqlite3_step(statement) != SQLITE_DONE {
            print("将视频添加到收藏夹失败: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(statement)
    }

    func removeVideoFromFavorite(videoId: String, favoriteId: String) {
        let deleteFavoriteVideoQuery = """
        DELETE FROM FavoriteVideos WHERE favoriteId = ? AND videoId = ?;
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteFavoriteVideoQuery, -1, &statement, nil) != SQLITE_OK {
            print("从收藏夹中删除视频失败: \(String(cString: sqlite3_errmsg(db)))")
            return
        }
        
        sqlite3_bind_text(statement, 1, favoriteId, -1, nil)
        sqlite3_bind_text(statement, 2, videoId, -1, nil)
        
        if sqlite3_step(statement) != SQLITE_DONE {
            print("从收藏夹中删除视频失败: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(statement)
    }

    
    deinit {
        sqlite3_close(db)
    }
}

