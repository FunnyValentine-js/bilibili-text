//
//  TabButton.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/5/23.
//

import SwiftUI

struct TabButton: View {
    let image: String
    let title: String
    let tag: Int
    @Binding var selectedTab: Int
    
    var body: some View {
        Button(action: {
            selectedTab = tag
        }) {
            VStack {
                Image(systemName: image)
                    .resizable()
                    .frame(width: 24, height: 24)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(selectedTab == tag ? .accentColor : .gray)
            .padding()
        }
        .frame(maxWidth: .infinity)
    }
}


