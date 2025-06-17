//
//  ContentView.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/5/23.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var isStatusBarHidden = false

    var body: some View {
        VStack{
            ZStack {
                NavigationView {
                    ZStack {
                        VStack {
                            ZStack {
                                if selectedTab == 0 {
                                    HomeView()
                                } else if selectedTab == 1 {
                                    DynamicView()
                                } else if selectedTab == 2 {
                                    CreationView()
                                } else if selectedTab == 3 {
                                    ShopView()
                                } else if selectedTab == 4 {
                                    ProfileView()
                                }
                            }
                        }
                       
                        Spacer()
                        VStack {
                            Spacer()
                            CustomTabBar(selectedTab: $selectedTab, isStatusBarHidden: $isStatusBarHidden)
                                .padding(.bottom, 10)
                                .padding(.top,0)
                                .frame(height: 60)
                        }
                        .ignoresSafeArea()

                    }
                    .edgesIgnoringSafeArea(.top) // 忽略顶部安全区
                    
                }
            }
            .edgesIgnoringSafeArea(.top) // 忽略顶部安全区
            .statusBar(hidden: isStatusBarHidden)
            .onAppear {
                print("ContentView appeared")
            }
            .onChange(of: selectedTab) { newValue in
                print("ContentView - Tab changed to: \(newValue)")
            }
            
        }
    }
    
}


#Preview {
    ContentView()
}
