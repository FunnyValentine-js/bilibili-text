//
//  DynamicView.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/5/23.
//

import SwiftUI

struct DynamicView: View {
    var body: some View {
        
            Image("DynamicPage")
                .resizable()
                .scaledToFill()
                .frame(height: 600)
        
    }
}

#Preview {
    DynamicView()
}
