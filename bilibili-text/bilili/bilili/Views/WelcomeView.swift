//
//  WelcomeView.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/5/25.
//

import SwiftUI

struct WelcomeView: View {
    @State private var isAnimating = false
    var dismissAction: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack{
                    Image("WelcomePage")
                        .resizable()
                        .scaledToFit()
                        .animation(
                            .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                        .ignoresSafeArea()
                }
                .ignoresSafeArea()
            }
            .navigationBarTitle("", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: dismissAction) {
                        Text("跳过")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .cornerRadius(15)
                    }
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            isAnimating = true
            // 5秒后自动消失
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                dismissAction()
            }
        }
    }
}


