//
//  NewCollectionView.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/6/10.
//

import SwiftUI

struct NewCollectionView: View {
    @EnvironmentObject var viewModel: VideoViewModel
    @Binding var isPresented: Bool
    @State private var newCollectionName = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("新建收藏夹")) {
                    TextField("收藏夹名称", text: $newCollectionName)
                }
            }
            .navigationTitle("新建收藏夹")
            .navigationBarItems(
                leading: Button("取消") {
                    isPresented = false
                    newCollectionName = ""
                },
                trailing: Button("创建") {
                    if !newCollectionName.isEmpty {
                        viewModel.databaseManager.addCollection(name: newCollectionName)
                        isPresented = false
                        newCollectionName = ""
                    }
                }
            )
        }
    }
}

