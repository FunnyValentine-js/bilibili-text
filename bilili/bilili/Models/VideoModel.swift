//
//  VideoModel.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/5/26.
//

import Foundation

// MARK: - 模型定义
struct Response: Decodable {
    let code: Int
    let data: [Video]?
    let msg: String
    
    enum CodingKeys: String, CodingKey {
        case code
        case data
        case msg
    }
}

// MARK: - 视频数据结构
struct Video: Identifiable, Decodable {  // 确保遵守 Decodable 协议
    let id: String /// ID 编号
    let isCoin: Bool /// 投币
    let isCoinCount: Int
    let isCollect: Bool
    let isCollectCount: Int
    let isDislike, isLike: Bool
    let isLikeCount: Int
    let thumbPhoto, title: String
    var upData: UpData
    
    enum CodingKeys: String, CodingKey {  // 自定义编码键（如果需要映射）
        case id
        case isCoin
        case isCoinCount
        case isCollect
        case isCollectCount
        case isDislike
        case isLike
        case isLikeCount
        case thumbPhoto
        case title
        case upData
    }
}

// MARK: - UpData
struct UpData: Decodable,Encodable {  // 确保遵守 Decodable 协议
    let avator: String
    var fans: Int /// 粉丝数
    var isFollow: Bool /// 是否关注
    let name: String
    let uid: String
    let videoCount: Int /// 发布视频数量
    
    enum CodingKeys: String, CodingKey {  // 自定义编码键（如果需要映射）
        case avator
        case fans
        case isFollow
        case name
        case uid
        case videoCount
    }
}

struct VideoCollection: Identifiable {
    let id: String
    let name: String
    let createdAt: Date
    var videoCount: Int = 0 // 可以在ViewModel中计算
}

