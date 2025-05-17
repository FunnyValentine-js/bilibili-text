//
//  ShopView.swift
//  bilibil
//
//  Created by SOSD_M1_2 on 2025/4/25.
//

import SwiftUI

struct ShopView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("会员购商城")
                        .font(.title)
                        .padding()
                    
                    ForEach(0..<8) { index in
                        ShopItemView(name: "商品 \(index+1)", price: "¥\(100 + index * 50)")
                    }
                }
            }
            .navigationTitle("会员购")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ShopItemView: View {
    let name: String
    let price: String
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(8)
            
            Text(name)
                .font(.headline)
            
            Text(price)
                .font(.subheadline)
                .foregroundColor(.red)
        }
        .padding()
        .frame(width: 150)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    ShopView()
}
