import Foundation
import SQLite3

class DatabaseManager : ObservableObject {
    private var db: OpaquePointer?
    private let dbPath: String = "videoFavorites.sqlite"
    
    static let shared = DatabaseManager() // 添加单例属性

    init() {
        db = openDatabase()
        createTables()
    }
    
    private func openDatabase() -> OpaquePointer? {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)
        
        var db: OpaquePointer?
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
            print("Successfully opened connection to database at \(fileURL.path)")
            return db
        } else {
            print("Unable to open database.")
            return nil
        }
    }
    
    private func createTables() {
        // 创建视频表
        let createVideoTableQuery = """
        CREATE TABLE IF NOT EXISTS Videos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            coverImage TEXT NOT NULL
        );
        """
        
        // 创建收藏夹表
        let createFavoritesTableQuery = """
        CREATE TABLE IF NOT EXISTS Favorites (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE
        );
        """
        
        // 创建视频-收藏夹关联表
        let createVideoFavoriteRelationTableQuery = """
        CREATE TABLE IF NOT EXISTS VideoFavoriteRelation (
            videoId INTEGER,
            favoriteId INTEGER,
            PRIMARY KEY (videoId, favoriteId),
            FOREIGN KEY (videoId) REFERENCES Videos(id) ON DELETE CASCADE,
            FOREIGN KEY (favoriteId) REFERENCES Favorites(id) ON DELETE CASCADE
        );
        """
        
        executeQuery(createVideoTableQuery)
        executeQuery(createFavoritesTableQuery)
        executeQuery(createVideoFavoriteRelationTableQuery)
    }
    
    private func executeQuery(_ query: String) {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Error executing query: \(errmsg)")
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Query preparation error: \(errmsg)")
        }
        sqlite3_finalize(statement)
    }
    
    // MARK: - 视频操作
    
    func addVideo(name: String, coverImage: String) -> Int {
        let insertQuery = "INSERT INTO Videos (name, coverImage) VALUES (?, ?);"
        var statement: OpaquePointer?
        var videoId: Int = -1
        
        if sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (coverImage as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                videoId = Int(sqlite3_last_insert_rowid(db))
                print("Video added successfully with ID: \(videoId)")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Failed to add video: \(errmsg)")
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Insert preparation failed: \(errmsg)")
        }
        
        sqlite3_finalize(statement)
        return videoId
    }
    
    func getAllVideos() -> [(id: Int, name: String, coverImage: String)] {
        let query = "SELECT id, name, coverImage FROM Videos;"
        var statement: OpaquePointer?
        var videos = [(Int, String, String)]()
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let name = String(cString: sqlite3_column_text(statement, 1))
                let coverImage = String(cString: sqlite3_column_text(statement, 2))
                videos.append((id, name, coverImage))
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error preparing select: \(errmsg)")
        }
        
        sqlite3_finalize(statement)
        return videos
    }
    
    // MARK: - 收藏夹操作
    
    func createFavoriteList(name: String) -> Int {
        let insertQuery = "INSERT INTO Favorites (name) VALUES (?);"
        var statement: OpaquePointer?
        var favoriteId: Int = -1
        
        if sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (name as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                favoriteId = Int(sqlite3_last_insert_rowid(db))
                print("Favorite list created successfully with ID: \(favoriteId)")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Failed to create favorite list: \(errmsg)")
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Insert preparation failed: \(errmsg)")
        }
        
        sqlite3_finalize(statement)
        return favoriteId
    }
    
    func getAllFavoriteLists() -> [(id: Int, name: String)] {
        let query = "SELECT id, name FROM Favorites;"
        var statement: OpaquePointer?
        var favorites = [(Int, String)]()
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let name = String(cString: sqlite3_column_text(statement, 1))
                favorites.append((id, name))
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error preparing select: \(errmsg)")
        }
        
        sqlite3_finalize(statement)
        return favorites
    }
    
    func deleteFavoriteList(id: Int) -> Bool {
        let deleteQuery = "DELETE FROM Favorites WHERE id = ?;"
        var statement: OpaquePointer?
        var success = false
        
        if sqlite3_prepare_v2(db, deleteQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(id))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Favorite list deleted successfully")
                success = true
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Failed to delete favorite list: \(errmsg)")
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Delete preparation failed: \(errmsg)")
        }
        
        sqlite3_finalize(statement)
        return success
    }
    
    // MARK: - 视频-收藏夹关系操作
    
    func addVideoToFavorite(videoId: Int, favoriteId: Int) -> Bool {
        let insertQuery = "INSERT INTO VideoFavoriteRelation (videoId, favoriteId) VALUES (?, ?);"
        var statement: OpaquePointer?
        var success = false
        
        if sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(videoId))
            sqlite3_bind_int(statement, 2, Int32(favoriteId))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Video added to favorite list successfully")
                success = true
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Failed to add video to favorite list: \(errmsg)")
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Insert preparation failed: \(errmsg)")
        }
        
        sqlite3_finalize(statement)
        return success
    }
    
    func removeVideoFromFavorite(videoId: Int, favoriteId: Int) -> Bool {
        let deleteQuery = "DELETE FROM VideoFavoriteRelation WHERE videoId = ? AND favoriteId = ?;"
        var statement: OpaquePointer?
        var success = false
        
        if sqlite3_prepare_v2(db, deleteQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(videoId))
            sqlite3_bind_int(statement, 2, Int32(favoriteId))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Video removed from favorite list successfully")
                success = true
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Failed to remove video from favorite list: \(errmsg)")
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Delete preparation failed: \(errmsg)")
        }
        
        sqlite3_finalize(statement)
        return success
    }
    
    func getVideosInFavoriteList(favoriteId: Int) -> [(id: Int, name: String, coverImage: String)] {
        let query = """
        SELECT v.id, v.name, v.coverImage 
        FROM Videos v
        JOIN VideoFavoriteRelation vfr ON v.id = vfr.videoId
        WHERE vfr.favoriteId = ?;
        """
        var statement: OpaquePointer?
        var videos = [(Int, String, String)]()
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(favoriteId))
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let name = String(cString: sqlite3_column_text(statement, 1))
                let coverImage = String(cString: sqlite3_column_text(statement, 2))
                videos.append((id, name, coverImage))
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error preparing select: \(errmsg)")
        }
        
        sqlite3_finalize(statement)
        return videos
    }
    
    deinit {
        sqlite3_close(db)
    }
}
