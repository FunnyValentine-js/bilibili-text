//
//  CollectionDetailView.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/6/10.
//

import SwiftUI

struct CollectionDetailView: View {
    @EnvironmentObject var viewModel: VideoViewModel
    let collection: VideoCollection
    @State private var videos: [Video] = []
    
    var body: some View {
        List {
            ForEach(videos) { video in
                VideoRowItemlView(video: video)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            viewModel.removeFromCollection(videoId: video.id, collectionId: collection.id)
                            refreshVideos()
                        } label: {
                            Label("移除", systemImage: "trash")
                        }
                    }
            }
        }
        .navigationTitle(collection.name)
        .onAppear {
            refreshVideos()
        }
    }
    
    private func refreshVideos() {
        videos = viewModel.getCollectionVideos(collectionId: collection.id)
    }
}
