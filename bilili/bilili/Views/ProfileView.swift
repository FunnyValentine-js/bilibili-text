//
//  ProfileView.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/5/23.
//
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userViewModel: UserViewModel // 管理用户数据
    @State private var isPickerPresented = false
    @State private var selectedImage: UIImage?
    @State private var showLogoutAlert = false // 控制退出确认弹窗
    @EnvironmentObject var viewModel: VideoViewModel
    @State private var showLogin = false // 控制登录页面跳转
    
    init() {
        // 设置导航栏的背景颜色
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground() // 透明背景
        appearance.backgroundColor = UIColor.white // 设置背景颜色
        appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "mainColor") ?? UIColor.black] // 设置标题文本颜色
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "mainColor") ?? UIColor.black] // 设置大标题文本颜色

        // 应用设置
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        VStack {
            // 顶部导航栏部分，显示头像和用户名
            HStack {
                // 检查用户是否登录
                if let currentUser = userViewModel.currentUser {
                    // 头像显示
                    if let url = userViewModel.getAvatar() {
                        AsyncImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 65, height: 65)
                        .clipShape(Circle())
                        .onTapGesture {
                            // 如果已登录，选择相册中的头像
                            self.isPickerPresented = true
                        }
                        .padding(.leading,25)
                    }
                } else {
                    // 如果没有登录，显示默认头像
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                        .frame(width: 65, height: 65)
                        .padding(.leading,25)
                }
                
                // 登录/用户名跳转
                NavigationLink(destination: LoginView(), isActive: $showLogin) {
                    Text(userViewModel.currentUser?.name ?? "未登录")
                        .font(.system(size: 25))
                        .padding(.leading, 8)
                        .padding(.bottom, 30)
                }
                .onTapGesture {
                    if userViewModel.currentUser == nil {
                        showLogin = true
                    }
                }
                
                Spacer()
                
                // 退出按钮 - 只在用户登录时显示
                if userViewModel.currentUser != nil {
                    Button(action: {
                        showLogoutAlert = true
                    }) {
                        Image(systemName: "power")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.red)
                            .padding(.trailing, 25)
                            .padding(.bottom,10)
                    }
                    .alert(isPresented: $showLogoutAlert) {
                        Alert(
                            title: Text("确认退出登录"),
                            message: Text("是否确认退出当前账号？"),
                            primaryButton: .destructive(Text("确认"), action: {
                                userViewModel.logout()
                            }),
                            secondaryButton: .cancel(Text("取消"))
                        )
                    }
                }
            }
            .padding(.top, 30)
            
            NavigationLink(destination: CollectionView()) {
                Image("ProfilePage")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // 使图片最大化
        .background(Color.white)
        .sheet(isPresented: $isPickerPresented, content: {
            ImagePicker(selectedImage: $selectedImage, isPresented: $isPickerPresented)
                .onDisappear {
//                    if let selectedImage = selectedImage {
//                        userViewModel.saveAvatar(selectedImage) // 保存头像
//                    }
                }
        })
        .onAppear {
            if let data = UserDefaults.standard.data(forKey: "currentUser"),
               let user = try? JSONDecoder().decode(User.self, from: data) {
                userViewModel.currentUser = user
            }
        }
    }
}

#Preview {
    ProfileView()
}

