/**
 * @file LoginView.swift
 * @description 登录页面视图，包含二维码和账号登录说明。
 * @author AI
 * @date 2025/6/5
 */
import SwiftUI

/// 登录页面视图
struct LoginView: View {
    /// 视图模型
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            // 二维码区域
            if let qrUrl = viewModel.qrUrl {
                // 这里用系统二维码生成（后续可替换为自定义）
                Image(uiImage: viewModel.generateQRCode(from: qrUrl))
                    .interpolation(.none)
                    .resizable()
                    .frame(width: 200, height: 200)
                    .cornerRadius(12)
                    .shadow(radius: 4)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 200, height: 200)
                    .overlay(
                        Text("二维码")
                            .foregroundColor(.gray)
                    )
                    .cornerRadius(12)
                    .shadow(radius: 4)
            }
            Button(action: {
                viewModel.fetchQRCode()
            }) {
                Text("重新生成二维码")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 24)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)
            }
            VStack(alignment: .center, spacing: 16) {
                Text("账号登录")
                    .font(.title)
                    .bold()
                Text("1 请打开 BiliBili 官方手机客户端扫码登录\n2 如果登录失败尝试点击重新生成二维码")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .background(Color(.white))
        .onAppear {
            viewModel.fetchQRCode()
        }
    }
} 
