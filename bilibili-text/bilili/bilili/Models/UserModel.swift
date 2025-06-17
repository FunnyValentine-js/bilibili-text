//
//  UserModel.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/5/25.
//
import SwiftUI
import Foundation

struct User: Identifiable, Codable{
    let id = UUID()
    let name: String
    let password: String
    var avatar: String? // 头像链接
    
    init(id: UUID = UUID(), name: String, password: String, avatar: String? = nil) {
        //self.id = id
        self.name = name
        self.password = password
        self.avatar = avatar
    }
}

