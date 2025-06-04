/**
 * @file LoginViewModel.swift
 * @description 登录模块ViewModel，负责处理登录逻辑。
 * @author AI
 * @date 2025/6/5
 */
import Foundation
import Combine
import CoreImage
import UIKit
import CryptoKit

/// 登录ViewModel
class LoginViewModel: ObservableObject {
    /// 用户名
    @Published var username: String = ""
    /// 密码
    @Published var password: String = ""
    /// 登录状态
    @Published var isLoggedIn: Bool = false
    /// 登录错误信息
    @Published var errorMessage: String? = nil
    /// 二维码URL
    @Published var qrUrl: String? = nil
    /// 二维码auth_code
    @Published var authCode: String? = nil
    
    /**
     * 执行登录操作
     */
    func login() {
        // 简单示例：用户名和密码都不为空即为登录成功
        if username.isEmpty || password.isEmpty {
            errorMessage = "用户名和密码不能为空"
            isLoggedIn = false
        } else {
            errorMessage = nil
            isLoggedIn = true
        }
    }
    
    func sign(for param: [String: Any]) -> [String: Any] {
        var newParam = param
        newParam["appkey"] = appkey
        newParam["ts"] = "\(Int(Date().timeIntervalSince1970))"
        newParam["local_id"] = "0"
        newParam["mobi_app"] = "iphone"
        newParam["device"] = "pad"
        newParam["device_name"] = "iPad"
        var rawParam = newParam
            .sorted(by: { $0.0 < $1.0 })
            .map({ "\($0.key)=\($0.value)" })
            .joined(separator: "&")
        rawParam.append(appsec)
        print("原始参数字符串: \(rawParam)")
        let md5 = Insecure.MD5
            .hash(data: rawParam.data(using: .utf8)!)
            .map { String(format: "%02hhx", $0) }
            .joined()
        newParam["sign"] = md5
        print("加密后参数字符串: \(md5)")
        return newParam
    }
    
    /// 获取二维码
    func fetchQRCode() {
        let url = URL(string: "https://passport.bilibili.com/x/passport-tv-login/qrcode/auth_code")!
        let headers = [
            "Accept-Encoding": "br;q=1.0, gzip;q=0.9, deflate;q=0.8",
            "User-Agent": "BilibiliLive/1.0 (com.etan.tv.BilibiliLive; build:1; tvOS 18.4.0) Alamofire/5.10.2",
            "Accept-Language": "zh-Hans-CN;q=1.0"
        ]
        let params: [String: Any] = [
            "local_id": "0",
            "device_name": "iPad",
            "ts": "1749063722",
            "appkey": appkey,
            "device": "pad",
            "mobi_app": "iphone"
        ]
        let body = try? JSONSerialization.data(withJSONObject: sign(for: params))
        NetworkManager.post(url: url, headers: headers, body: body) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let json = try? JSONSerialization.jsonObject(with: response.data) as? [String: Any],
                       let data = json["data"] as? [String: Any],
                       let qrUrl = data["url"] as? String,
                       let authCode = data["auth_code"] as? String {
                        self.qrUrl = qrUrl
                        self.authCode = authCode
                    } else {
                        self.qrUrl = nil
                        self.authCode = nil
                    }
                case .failure(_):
                    self.qrUrl = nil
                    self.authCode = nil
                }
            }
        }
    }
    
    /// 生成二维码图片
    func generateQRCode(from string: String) -> UIImage {
        let data = string.data(using: .utf8)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("M", forKey: "inputCorrectionLevel")
            if let outputImage = filter.outputImage {
                let scaled = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
                return UIImage(ciImage: scaled)
            }
        }
        return UIImage()
    }
} 
