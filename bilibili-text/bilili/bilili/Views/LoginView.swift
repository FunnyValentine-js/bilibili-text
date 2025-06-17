//
//  LoginView.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/5/25.
//

import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var loginError: String? = nil
    @State private var isLoading: Bool = false
    @State private var isPasswordFieldFocused: Bool = false
    
    @StateObject var userViewModel = UserViewModel() // 管理用户数据
    @Environment(\.presentationMode) var presentationMode // 用于返回上一级视图
    
    var body: some View {
        VStack {
            // 根据是否在密码输入状态显示不同图标
            if isPasswordFieldFocused {
                Image("password2")
                    .resizable()
                    .scaledToFit()
            } else {
                Image("password1")
                    .resizable()
                    .scaledToFit()
            }
            
            // 用户名输入框
            TextField("请输入用户名", text: $username)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.gray, lineWidth: 1))
                .padding(.horizontal)
                .onTapGesture {
                    isPasswordFieldFocused = false
                }
            
            // 密码输入框
            SecureField("请输入密码", text: $password)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.gray, lineWidth: 1))
                .padding(.horizontal)
                .onTapGesture {
                    isPasswordFieldFocused = true
                }
                .onChange(of: password) { _ in
                    // 当密码变化时保持禁止图标
                    isPasswordFieldFocused = true
                }
            
            // 错误提示
            if let error = loginError {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            
            // 登录按钮
            Button(action: {
                isPasswordFieldFocused = false
                login()
            }) {
                Text(isLoading ? "登录中..." : "登录")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.accent)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .disabled(isLoading)
            
            Spacer()
        }
        .padding()
        .onTapGesture {
            // 点击空白处恢复电视图标
            isPasswordFieldFocused = false
        }
        .navigationTitle("登录")
//        .navigationBarTitleDisplayMode(.large)
    }
    
    // 登录请求（使用 UserViewModel 进行登录）
    func login() {
        guard !username.isEmpty, !password.isEmpty else {
            loginError = "用户名和密码不能为空"
            return
        }

        isLoading = true
        loginError = nil
        
        userViewModel.login(account: username, password: password) { success, error in
            DispatchQueue.main.async {
                if success {
                    // 登录成功，跳转到其他页面（例如ProfileView）
                    print("登录成功")
                    presentationMode.wrappedValue.dismiss() // 执行返回操作
                } else {
                    loginError = error
                }
                isLoading = false
            }
        }
    }
}
