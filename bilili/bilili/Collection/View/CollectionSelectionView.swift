//
//  CollectionSelectionView.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/6/10.
//

import SwiftUI

struct CollectionSelectionView: View {
    @EnvironmentObject var viewModel: VideoViewModel
    @Binding var isPresented: Bool
    let videoId: String
    @State private var selectedCollections: Set<String> = []
    
    var availableCollections: [VideoCollection] {
        viewModel.getAvailableCollections(for: videoId)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if availableCollections.isEmpty {
                    Text("所有收藏夹中已包含此视频")
                        .foregroundColor(.gray)
                        .padding()
                    
                    Button("确定") {
                        isPresented = false
                    }
                    .padding()
                } else {
                    List {
                        ForEach(availableCollections) { collection in
                            HStack {
                                Image(systemName: selectedCollections.contains(collection.id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(.blue)
                                Text(collection.name)
                                Spacer()
                                Text("\(collection.videoCount)个视频")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectedCollections.contains(collection.id) {
                                    selectedCollections.remove(collection.id)
                                } else {
                                    selectedCollections.insert(collection.id)
                                }
                            }
                        }
                    }
                    
                    HStack {
                        Button("取消") {
                            isPresented = false
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                        
                        Button("确认") {
                            if !selectedCollections.isEmpty {
                                viewModel.addVideoToCollections(
                                    videoId: videoId,
                                    collectionIds: Array(selectedCollections)
                                )
                            }
                            isPresented = false
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedCollections.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(selectedCollections.isEmpty)
                    }
                    .padding()
                }
            }
            .navigationTitle("选择收藏夹")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

