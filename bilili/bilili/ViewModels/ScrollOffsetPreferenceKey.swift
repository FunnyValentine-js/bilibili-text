//
//  ScrollOffsetPreferenceKey.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/5/27.
//

import Foundation
import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
