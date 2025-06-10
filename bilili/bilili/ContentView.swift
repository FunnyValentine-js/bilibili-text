//
//  ContentView.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/5/23.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
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
                
                VStack {
                    Spacer()
                    
                    CustomTabBar(selectedTab: $selectedTab)
                        .padding(.bottom, 0)
                }
                .ignoresSafeArea()
                .edgesIgnoringSafeArea(.top)
                .edgesIgnoringSafeArea(.bottom) 
            }
        }
    }
}


#Preview {
    ContentView()
}
