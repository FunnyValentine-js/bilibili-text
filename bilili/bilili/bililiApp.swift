//
//  bililiApp.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/5/23.
//

import SwiftUI

@main
struct bililiApp: App {
    @State private var showWelcome = true
    @StateObject var viewModel: VideoViewModel
    
    init() {
        let databasePath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        ).first! + "/videos.db"
        _viewModel = StateObject(wrappedValue: VideoViewModel(databasePath: databasePath))
    }
    var body: some Scene {
        WindowGroup {
            Group {
                ContentView()
            }
            .environmentObject(viewModel)
            .overlay {
                if showWelcome {
                    WelcomeView {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showWelcome = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showWelcome)
        }
    }
}
