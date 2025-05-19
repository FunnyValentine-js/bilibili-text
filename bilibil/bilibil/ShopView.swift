//
//  ShopView.swift
//  bilibil
//
//  Created by SOSD_M1_2 on 2025/4/25.
//

import SwiftUI

/**
 * @file ShopView.swift
 * @description 会员购商城页面，展示商品列表。
 * @author SOSD_M1_2
 * @date 2025/4/25
 */

/**
 * @struct ShopView
 * @description 会员购主页面，包含商品列表。
 */
struct ShopView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    /**
                     * 页面标题。
                     */
                    Text("会员购商城")
                        .font(.title)
                        .padding()
                    
                    /**
                     * 商品卡片列表，模拟8个商品。
                     */
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

/**
 * @struct ShopItemView
 * @description 单个商品卡片，展示商品图片、名称、价格。
 * @property {String} name 商品名称。
 * @property {String} price 商品价格。
 */
struct ShopItemView: View {
    let name: String
    let price: String
    
    var body: some View {
        VStack {
            // 商品图片（灰色矩形占位）
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(8)
            
            // 商品名称
            Text(name)
                .font(.headline)
            
            // 商品价格
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
