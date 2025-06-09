//
//  PlayerViewModel.swift
//  bilili
//
//  Created by SOSD_M1_2 on 2025/6/1.
//

import SwiftUI
import AVKit
import Combine

class PlayerViewModel: ObservableObject {
    // 播放器状态
    @Published var player: AVPlayer?
    @Published var showControls = true
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var isFullscreen = false
    @Published var showSpeedOptions = false
    @Published var playbackRate: Float = 1.0
    @Published var isDraggingSlider = false
    @Published var showLoadingIndicator = true
    
    private var cancellables = Set<AnyCancellable>()
    private var timeObserver: Any?
    
    init(videoURL: String) {
        if let url = URL(string: videoURL) {
            self.player = AVPlayer(url: url)
            setupPlayer()
        }
    }
    
    deinit {
        cleanup()
    }
    
    private func setupPlayer() {
        guard let player = player else { return }
        
        // 获取视频时长
        if let duration = player.currentItem?.asset.duration {
            self.duration = CMTimeGetSeconds(duration)
        }
        
        // 添加时间观察者
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self = self, !self.isDraggingSlider else { return }
            self.currentTime = CMTimeGetSeconds(time)
        }
        
        // 监听播放状态
        NotificationCenter.default
            .publisher(for: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            .sink { [weak self] _ in
                self?.handlePlaybackEnd()
            }
            .store(in: &cancellables)
        
        // 监听缓冲状态
        player.currentItem?.publisher(for: \.status)
            .sink { [weak self] status in
                self?.handlePlayerStatus(status)
            }
            .store(in: &cancellables)
        
        // 自动播放
        play()
        
        // 3秒后隐藏加载指示器
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.showLoadingIndicator = false
        }
    }
    
    private func cleanup() {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        pause()
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - 公共方法
    
    func togglePlayPause() {
        isPlaying ? pause() : play()
    }
    
    func play() {
        player?.play()
        player?.rate = playbackRate
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func seek(to time: Double) {
        let targetTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: targetTime)
    }
    
    func toggleFullscreen() {
        if isFullscreen {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
        isFullscreen.toggle()
    }
    
    func setPlaybackRate(_ rate: Float) {
        playbackRate = rate
        if isPlaying {
            player?.rate = rate
        }
    }
    
    // MARK: - 私有方法
    
    private func handlePlaybackEnd() {
        isPlaying = false
        seek(to: 0)
    }
    
    private func handlePlayerStatus(_ status: AVPlayerItem.Status) {
        DispatchQueue.main.async { [weak self] in
            switch status {
            case .readyToPlay:
                self?.showLoadingIndicator = false
            case .failed:
                self?.showLoadingIndicator = false
                // 可以添加错误处理逻辑
            default:
                break
            }
        }
    }
}
