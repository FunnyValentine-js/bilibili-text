//
//  VideoPlayer.swift
//  bilibil
//
//  Created by SOSD_M1_2 on 2025/5/17.
//

import SwiftUI
import AVKit
import Combine

struct CustomVideoPlayerView: View {
    let videoURL = URL(string: "https://media.w3.org/2010/05/sintel/trailer.mp4")!
    @State private var player: AVPlayer
    @State private var isPlaying = false
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var isFullscreen = false
    @State private var controlsVisible = true // 控制控制栏是否可见
    @State private var orientation = UIDeviceOrientation.portrait
    private let progressTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    init() {
        self._player = State(initialValue: AVPlayer(url: videoURL))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 视频播放器层（始终在底层）
                VideoPlayer(player: player)
                    .disabled(true)
                    .frame(height: isFullscreen ? geometry.size.height : geometry.size.height / 3)
                    .onTapGesture {
                        toggleControls()
                    }
                    .onReceive(progressTimer) { _ in
                        updateProgress()
                    }
                    .onAppear {
                        setupPlayer()
                    }
                    .onDisappear {
                        player.pause()
                    }
                
                // 控制层（根据controlsVisible决定是否显示）
                if controlsVisible {
                    controlsLayer
                        .frame(height: isFullscreen ? geometry.size.height : geometry.size.height / 3)
                        .onTapGesture {
                            toggleControls()
                        }
                }
                controlsLayer
                    .frame(height: isFullscreen ? geometry.size.height : geometry.size.height / 3)
                    .onTapGesture {
                        toggleControls()
                    }
                    .opacity(0.1)
                // 隐藏控制层的透明区域，点击显示/隐藏控制层
//                Color.clear
//                    .onTapGesture {
//                        toggleControls()
//                    }
            }
            .background(Color.black)
            .edgesIgnoringSafeArea(isFullscreen ? .all : [])
            .statusBarHidden(isFullscreen)
            .onRotate { newOrientation in
                orientation = newOrientation
                if orientation.isLandscape {
                    isFullscreen = true
                } else {
                    isFullscreen = false
                }
            }
        }
    }
    
    // 控制层视图
    private var controlsLayer: some View {
        ZStack(alignment: .bottom) {
            // 半透明遮罩背景
            Color.black.opacity(0.3)
                .contentShape(Rectangle())
            
            // 顶部控制栏
            VStack {
                HStack {
                    // 返回按钮
                    Button(action: {
                        if isFullscreen {
                            toggleFullscreen()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                    
                    Spacer()
                    
                    // 更多按钮
                    Button(action: {
                        // 更多操作
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                Spacer()
            }
            
            // 底部控制栏
            VStack {
                Spacer()
                
                HStack {
                    // 播放/暂停按钮
                    Button(action: {
                        togglePlayPause()
                    }) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                    
                    // 当前时间
                    Text(formatTime(seconds: currentTime))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 40)
                    
                    // 进度条
                    Slider(value: $currentTime, in: 0...duration, onEditingChanged: { editing in
                        sliderEditingChanged(editingStarted: editing)
                    })
                    .accentColor(.pink)
                    
                    // 总时间
                    Text(formatTime(seconds: duration))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 40)
                    
                    // 全屏按钮
                    Button(action: {
                        toggleFullscreen()
                    }) {
                        Image(systemName: isFullscreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
    }
    
    // 设置播放器
    private func setupPlayer() {
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { time in
            updateProgress()
        }
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            isPlaying = false
            player.seek(to: .zero)
        }
        
        // 初始获取视频时长
        if let duration = player.currentItem?.asset.duration, CMTIME_IS_VALID(duration) {
            self.duration = duration.seconds
        }
    }
    
    // 更新进度
    private func updateProgress() {
        guard let currentItem = player.currentItem else { return }
        
        // 更新当前时间
        let currentCMTime = currentItem.currentTime()
        self.currentTime = currentCMTime.seconds.isNaN ? 0 : currentCMTime.seconds
        
        // 更新总时长
        let durationCMTime = currentItem.duration
        if CMTIME_IS_VALID(durationCMTime) && !durationCMTime.seconds.isNaN {
            self.duration = durationCMTime.seconds
        }
    }
    
    // 切换播放/暂停
    private func togglePlayPause() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
    
    // 切换全屏
    private func toggleFullscreen() {
        if isFullscreen {
            // 强制竖屏
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        } else {
            // 强制横屏
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
        isFullscreen.toggle()
    }
    
    // 格式化时间
    private func formatTime(seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // 处理进度条滑动
    private func sliderEditingChanged(editingStarted: Bool) {
        if !editingStarted {
            let targetTime = CMTime(seconds: currentTime, preferredTimescale: 600)
            player.seek(to: targetTime)
        }
    }
    
    // 切换控制栏显示状态
    private func toggleControls() {
        withAnimation(.easeInOut(duration: 0.2)) {
            controlsVisible.toggle()
        }
    }
}

// 屏幕旋转检测
struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

// 预览
struct CustomVideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        CustomVideoPlayerView()
    }
}

// AVPlayer扩展
extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
