//
//  VideoRowItemView.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/6/1.
//

import SwiftUI

struct VideoRowItemlView: View {
    let video: Video

    var body: some View {
        NavigationLink(destination: VideoDetailView(video: video,isFollowing: video.upData.isFollow,isLiking: video.isLike,isDisliking: video.isDislike,isCoining: video.isCoin,isCollectwing: video.isCollect)) {
            HStack {
                // Top third of the cell shows the thumbnail
                AsyncImage(url: URL(string: video.thumbPhoto)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: UIScreen.main.bounds.width / 2 - 20, height: UIScreen.main.bounds.width / 2 - 80)
                            .background(Color.gray)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width / 2 - 20, height: UIScreen.main.bounds.width / 2 - 80)
                            .clipped()
                    case .failure:
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .resizable()
                                .scaledToFill()
                                .foregroundColor(.black)
                                .background(Color.gray)
                        }
                        .frame(width: UIScreen.main.bounds.width / 2 - 20, height: UIScreen.main.bounds.width / 2 - 80)
                        .clipped()
                    @unknown default:
                        EmptyView()
                    }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    // Bottom third of the cell shows the title
                    Text(video.title)
                        .font(.system(size: 15))
                        .lineLimit(2)
                        .padding(.bottom, 5)
                        .frame(width: UIScreen.main.bounds.width / 2 - 30, height: UIScreen.main.bounds.width / 2 - 150, alignment: .topLeading)
                        .background(Color.white)
                    
                    Text(video.upData.name)
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 10)
                    
                }
                .frame(width: UIScreen.main.bounds.width / 2 - 30, height: UIScreen.main.bounds.width / 2 - 120)
                .padding(.leading, 5)
            }
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 5)
        }
    }
}
