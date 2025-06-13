//
//  UserViewModel.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/5/27.
//

import Foundation
import SwiftUI

/// 登录接口响应结构体
struct LoginResponse: Codable {
    let code: Int
    let msg: String
    let name: String?
    let avatar: String?
}

class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var currentUser: User?
    
    init() {
        // 尝试从UserDefaults加载已登录用户
        if let data = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            
            DispatchQueue.main.async {
                self.currentUser = user
            }
        }
    }
    
    // 登录功能
    func login(account: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        guard !account.isEmpty, !password.isEmpty else {
            completion(false, "用户名和密码不能为空")
            return
        }
        
        let parameters = """
        {
            "username": "\(account)",
            "password": "\(password)"
        }
        """
        let postData = parameters.data(using: .utf8)
        
        guard let url = URL(string: "https://apiv1.ssgpt.chat/login") else {
            completion(false, "无效的 URL")
            return
        }

        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, "登录失败: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                completion(false, "无响应数据")
                return
            }

            // 打印接口返回的原始数据
            print("接口响应数据: \(String(data: data, encoding: .utf8) ?? "")")

            do {
                let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                if loginResponse.code == 200,
                   let name = loginResponse.name {
                    let user = User(name: name, password: password, avatar: loginResponse.avatar)
                    DispatchQueue.main.async {
                        self.currentUser = user
                        self.saveCurrentUser()
                        completion(true, nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false, loginResponse.msg)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, "解析响应失败")
                }
            }
        }

        task.resume()
    }
    
    // 保存当前用户到UserDefaults
    func saveCurrentUser() {
        if let user = currentUser,
           let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: "currentUser")
        }
    }
    
    // 获取头像
    func getAvatar() -> URL? {
        guard let avatarUrl = currentUser?.avatar else {
            return nil
        }
        return URL(string: avatarUrl)
    }
    
    // 退出登录
    func logout() {
        DispatchQueue.main.async {
            self.currentUser = nil
            UserDefaults.standard.removeObject(forKey: "currentUser")
        }
    }
}
