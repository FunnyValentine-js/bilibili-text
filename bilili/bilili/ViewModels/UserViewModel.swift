//
//  UserViewModel.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/5/27.
//

import Foundation
import SwiftUI


class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var currentUser: User?
    
    init() {
        // 尝试从UserDefaults加载已登录用户
        if let data = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
        }
    }
    
    // 登录功能
    func login(account: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        guard !account.isEmpty, !password.isEmpty else {
            completion(false, "用户名和密码不能为空")
            return
        }
        
        // 这里是模拟的登录请求，替换为真实请求
        let parameters = """
        {
            "username": "\(account)",
            "password": "\(password)"
        }
        """
        let postData = parameters.data(using: .utf8)
        
        guard let url = URL(string: "http://127.0.0.1:4523/m1/6447670-6145983-default/user/log/psw") else {
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

            if let responseString = String(data: data, encoding: .utf8) {
                print("响应数据: \(responseString)")
                // 假设登录成功，设置currentUser
                let user = User(name: account, password: password,avatar: nil)
                self.currentUser = user
                self.saveCurrentUser() // 保存当前用户
                completion(true, nil)
            } else {
                completion(false, "登录失败")
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
    
    // 保存头像
    func saveAvatar(_ image: UIImage) {
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            currentUser?.avatar = imageData
            saveCurrentUser()
        }
    }
    
    // 获取头像
    func getAvatar() -> UIImage? {
        guard let avatarData = currentUser?.avatar else {
            return nil
        }
        return UIImage(data: avatarData)
    }
    
    // 退出登录
    func logout() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
}
