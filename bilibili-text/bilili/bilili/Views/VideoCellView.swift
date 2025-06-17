//
//  VideoCellView.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/5/27.
//

import SwiftUI

// MARK: - VideoCell视图
struct VideoCellView: View {
    let video: Video

    var body: some View {
        NavigationLink(destination: VideoDetailView(video: video,isFollowing: video.upData.isFollow,isLiking: video.isLike,isDisliking: video.isDislike,isCoining: video.isCoin,isCollectwing: video.isCollect)) {
            VStack{
                ZStack{
                    AsyncImage(url: URL(string: video.thumbPhoto)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: UIScreen.main.bounds.width / 2 - 10, height: UIScreen.main.bounds.width / 2 - 60)
                                .background(Color.gray)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width / 2 - 10, height: UIScreen.main.bounds.width / 2 - 60)
                                .clipped()
                        case .failure:
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .resizable()
                                    .scaledToFill()
                                    .foregroundColor(.black)
                                    .background(Color.gray)
                            }
                            .frame(width: UIScreen.main.bounds.width / 2 - 10, height: UIScreen.main.bounds.width / 2 - 60)
                            .clipped()
                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    VStack{
                        Spacer()
                        HStack(spacing: 5){
                            Image("播放量")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .padding(.leading,5)
                        
                            Text("1145")
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                
                            Image("评论")
                                .resizable()
                                .frame(width: 15, height: 15)
                                
                        
                            Text("14")
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("19:19")
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .padding(.trailing,5)
                            
                        }
                        .padding(.bottom,5)
                        .background(Color.black.opacity(0.2))
                    }
                    
                   
                }
                
                
                
                VStack(alignment: .leading, spacing: 0) {
                   
                    Text(video.title)
                        .font(.system(size: 15))
                        .lineLimit(2)
                        .padding(.top,0)
                        .padding(.bottom, 0)
                        .frame(width: UIScreen.main.bounds.width / 2 - 30, height: UIScreen.main.bounds.width / 2 - 150, alignment: .topLeading)
                        .multilineTextAlignment(.leading) // 添加这一行，确保多行文本左对齐
                        .foregroundColor(.black)
                        .background(Color.white)
                    
                    HStack {
                        Image("UP主_32")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .padding(.leading, 3)
                            .padding(.bottom, 10)
                            .foregroundColor(.gray)
                        Text(video.upData.name)
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 10)
                        Spacer()
                        Image("更多")
                            .resizable()
                            .frame(width: 10, height: 10)
                            .padding(.trailing, 5)
                            .padding(.bottom, 10)
                            .foregroundColor(.gray)
                    }
                    .padding(.top,0)
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

