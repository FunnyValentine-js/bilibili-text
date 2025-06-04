/**
 * @file NetworkManager.swift
 * @description 系统原生HTTP请求工具类，支持GET/POST方法，封装请求头、请求体、响应头、响应体。
 * @author AI
 * @date 2025/6/5
 */
import Foundation
import CryptoKit

public let appkey = "5ae412b53418aac5"
public let appsec = "5b9cf6c9786efd204dcf0c1ce2d08436"


/// HTTP请求方法
public enum HTTPMethod: String {
    case GET
    case POST
}

/// 网络请求结果
public struct HTTPResponse {
    /// 响应头
    public let headers: [AnyHashable: Any]
    /// 响应体
    public let data: Data
    /// HTTP状态码
    public let statusCode: Int
}


/// 网络请求管理器
public class NetworkManager {
    /**
     * 发送HTTP请求
     * - Parameters:
     *   - url: 请求地址
     *   - method: 请求方法（GET/POST）
     *   - headers: 请求头
     *   - body: 请求体（POST时可用）
     *   - completion: 完成回调，返回HTTPResponse或错误
     */
    public static func request(url: URL, method: HTTPMethod = .GET, headers: [String: String]? = nil, body: Data? = nil, completion: @escaping (Result<HTTPResponse, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        if let body = body {
            request.httpBody = body
        }
        print("[NetworkManager] 请求URL: \(url)")
        print("[NetworkManager] 请求方法: \(method.rawValue)")
        if let headers = headers {
            print("[NetworkManager] 请求头: \(headers)")
        }
        if let body = body, let bodyStr = String(data: body, encoding: .utf8) {
            print("[NetworkManager] 请求体: \(bodyStr)")
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("[NetworkManager] 请求失败: \(error)")
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                print("[NetworkManager] 无响应")
                completion(.failure(NSError(domain: "NetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "无响应"])))
                return
            }
            let headers = httpResponse.allHeaderFields
            let statusCode = httpResponse.statusCode
            print("[NetworkManager] 响应头: \(headers)")
            print("[NetworkManager] 状态码: \(statusCode)")
            if let respStr = String(data: data, encoding: .utf8) {
                print("[NetworkManager] 响应体: \(respStr)")
            }
            let resp = HTTPResponse(headers: headers, data: data, statusCode: statusCode)
            completion(.success(resp))
        }
        task.resume()
    }
    
    /**
     * GET请求
     */
    public static func get(url: URL, headers: [String: String]? = nil, completion: @escaping (Result<HTTPResponse, Error>) -> Void) {
        request(url: url, method: .GET, headers: headers, completion: completion)
    }
    
    /**
     * POST请求
     */
    public static func post(url: URL, headers: [String: String]? = nil, body: Data? = nil, completion: @escaping (Result<HTTPResponse, Error>) -> Void) {
        request(url: url, method: .POST, headers: headers, body: body, completion: completion)
    }
    

}
