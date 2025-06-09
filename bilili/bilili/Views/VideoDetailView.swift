import SwiftUI
import AVKit

struct VideoDetailView: View {
    let video: Video
    @State var isFollowing: Bool
    @State var isLiking: Bool
    @State var isDisliking: Bool
    @State var isCoining: Bool
    @State var isCollectwing: Bool
    
    @StateObject private var viewModel = VideoViewModel(
        databasePath: NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        ).first! + "/videos.db"
    )
    @StateObject private var playerVM: PlayerViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(video: Video, isFollowing: Bool, isLiking: Bool, isDisliking: Bool, isCoining: Bool, isCollectwing: Bool) {
        self.video = video
        self._isFollowing = State(initialValue: isFollowing)
        self._isLiking = State(initialValue: isLiking)
        self._isDisliking = State(initialValue: isDisliking)
        self._isCoining = State(initialValue: isCoining)
        self._isCollectwing = State(initialValue: isCollectwing)
        self._playerVM = StateObject(wrappedValue: PlayerViewModel(videoURL: "https://media.w3.org/2010/05/sintel/trailer.mp4"))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 5) {
                // 视频播放器区域
                ZStack {
                    if playerVM.player != nil {
                        CustomVideoPlayer(player: playerVM.player!)
                            .frame(height: playerVM.isFullscreen ? UIScreen.main.bounds.height : 220)
                            .onTapGesture {
                                withAnimation {
                                    playerVM.showControls.toggle()
                                }
                            }
                            .onAppear {
                                playerVM.play()
                            }
                            .onDisappear {
                                playerVM.pause()
                            }
                        
                        // 加载指示器
                        if playerVM.showLoadingIndicator {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                        }
                        
                        // 自定义控制层
                        if playerVM.showControls {
                            controlsOverlay
                        }
                        
                        // 播放按钮（当视频暂停且控件隐藏时显示）
                        if !playerVM.isPlaying && !playerVM.showControls {
                            Button(action: {
                                playerVM.togglePlayPause()
                            }) {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    } else {
                        // 视频加载失败时的占位图
                        Color.gray
                            .frame(height: playerVM.isFullscreen ? UIScreen.main.bounds.height : 220)
                            .overlay(
                                VStack {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundColor(.white)
                                        .font(.title)
                                    Text("视频加载失败")
                                        .foregroundColor(.white)
                                        .padding(.top, 5)
                                }
                            )
                    }
                }
                .background(Color.black)
                .edgesIgnoringSafeArea(playerVM.isFullscreen ? .all : [])
                .statusBar(hidden: playerVM.isFullscreen)
                .onRotate { orientation in
                    if orientation.isLandscape {
                        playerVM.isFullscreen = true
                    } else if orientation.isPortrait {
                        playerVM.isFullscreen = false
                    }
                }
                
                // 用户信息区域
                userInfoSection
                
                // 视频标题
                Text(video.title)
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .frame(width: UIScreen.main.bounds.width, alignment: .topLeading)
                    .padding(.top, 10)
                
                // 互动按钮区域
                interactionButtons
                
                // 相关视频推荐
                VideoRowView()
            }
            .padding()
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
    }
    
    // 用户信息区域
    private var userInfoSection: some View {
        HStack {
            AsyncImage(url: URL(string: video.upData.avator)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 40, height: 40)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: 40, height: 40)
                case .failure:
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                @unknown default:
                    EmptyView()
                }
            }
            .padding(.horizontal, 10)
            
            VStack(alignment: .leading) {
                Text(video.upData.name)
                    .font(.headline)
                    .foregroundColor(.pink)
                
                HStack {
                    Text("11.4万粉丝")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Text("\(video.upData.videoCount)视频")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button(action: {
                isFollowing.toggle()
            }) {
                Text(isFollowing ? "已关注" : "关注")
                    .font(.headline)
                    .foregroundColor(isFollowing ? Color.black : Color.white)
                    .frame(width: 70, height: 15)
                    .padding(7)
                    .background(isFollowing ? Color.gray : Color.pink)
                    .clipShape(Capsule())
                    .padding(.horizontal, 10)
            }
        }
        .padding(.top, 10)
    }
    
    // 互动按钮区域
    private var interactionButtons: some View {
        HStack {
            Button(action: {
                isLiking.toggle()
            }) {
                VStack {
                    Image(systemName: "hand.thumbsup.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(isLiking ? Color.pink : Color.gray)
                        .frame(width: 30)
                    Text(isLiking ? formatLikeCount(video.isLikeCount + 1) : formatLikeCount(video.isLikeCount))
                        .font(.system(size: 10))
                        .frame(width: 30)
                }
            }
            .padding(.leading, 20)
            
            Spacer()
            
            Button(action: {
                isDisliking.toggle()
            }) {
                VStack {
                    Image(systemName: "hand.thumbsdown.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(isDisliking ? Color.pink : Color.gray)
                        .frame(width: 30)
                    Text("不喜欢")
                        .font(.system(size: 10))
                        .frame(width: 40)
                }
            }
            
            Spacer()
            
            Button(action: {
                isCoining.toggle()
            }) {
                VStack {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(isCoining ? Color.pink : Color.gray)
                        .frame(width: 30)
                    Text(isCoining ? formatLikeCount(video.isCoinCount + 1) : formatLikeCount(video.isCoinCount))
                        .font(.system(size: 10))
                        .frame(width: 30)
                }
            }
            
            Spacer()
            
            Button(action: {
                isCollectwing.toggle()
            }) {
                VStack {
                    Image(systemName: "star.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(isCollectwing ? Color.pink : Color.gray)
                        .frame(width: 30)
                    Text(isCollectwing ? formatLikeCount(video.isCollectCount + 1) : formatLikeCount(video.isCollectCount))
                        .font(.system(size: 10))
                        .frame(width: 30)
                }
            }
            
            Spacer()
            
            Button(action: {
                // 分享操作
            }) {
                VStack {
                    Image(systemName: "arrowshape.turn.up.forward.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.gray)
                        .frame(width: 30)
                    Text("分享")
                        .font(.system(size: 10))
                        .frame(width: 30)
                }
            }
            .padding(.trailing, 20)
        }
        .padding(.top, 10)
    }
    
    // 自定义控制层
    private var controlsOverlay: some View {
        ZStack(alignment: .bottom) {
//            // 半透明背景
//            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]), startPoint: .top, endPoint: .bottom)
//                .frame(height: 60)
//                .padding(.bottom, playerVM.isFullscreen ? 30 : 0)
            
            // 顶部控制按钮
            VStack {
                HStack {
                    // 左上角返回按钮
                    Button(action: {
                        if playerVM.isFullscreen {
                            playerVM.toggleFullscreen()
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Circle().fill(Color.black.opacity(0.7)))
                    }
                    .padding(.leading, 15)
                    .padding(.top, playerVM.isFullscreen ? 50 : 15)
                    
                    Spacer()
                    
                    // 播放速度选项
                    if playerVM.showSpeedOptions {
                        HStack(spacing: 4) {
                            ForEach([0.5, 1.0, 1.5, 2.0], id: \.self) { speed in
                                Button(action: {
                                    playerVM.setPlaybackRate(Float(speed))
                                    withAnimation {
                                        playerVM.showSpeedOptions = false
                                    }
                                }) {
                                    Text("\(speed, specifier: "%g")×")
                                        .font(.system(size: 12))
                                        .foregroundColor(playerVM.playbackRate == Float(speed) ? .pink : .white)
                                        .padding(4)
                                        .background(Color.black.opacity(0.7))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(4)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                        .padding(.trailing, 10)
                        .padding(.top, playerVM.isFullscreen ? 40 : 20)
                    }
                    
                    // 右上角更多按钮（播放速度）
                    Button(action: {
                        withAnimation {
                            playerVM.showSpeedOptions.toggle()
                        }
                    }) {
                        Image(systemName: "speedometer")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Circle().fill(Color.black.opacity(0.7)))
                    }
                    .padding(.trailing, 15)
                    .padding(.top, playerVM.isFullscreen ? 50 : 15)
                }
                
                Spacer()
            }
            
            // 底部控制按钮
            VStack(spacing: 5) {
                HStack {
                    // 播放/暂停按钮
                    Button(action: {
                        playerVM.togglePlayPause()
                    }) {
                        Image(systemName: playerVM.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.leading, 15)
                    }
                    
                    // 时间显示
                    Text(formattedTime(playerVM.currentTime))
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .frame(width: 50)
                    
                    // 进度条
                    Slider(
                        value: $playerVM.currentTime,
                        in: 0...playerVM.duration,
                        onEditingChanged: { editing in
                            playerVM.isDraggingSlider = editing
                            if !editing {
                                playerVM.seek(to: playerVM.currentTime)
                            }
                        }
                    )
                    .accentColor(.pink)
                    .padding(.horizontal, 10)
                    
                    // 总时长
                    Text(formattedTime(playerVM.duration))
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .frame(width: 50)
                    
                    // 全屏按钮
                    Button(action: {
                        playerVM.toggleFullscreen()
                    }) {
                        Image(systemName: playerVM.isFullscreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.trailing, 15)
                    }
                }
            }
            .padding(.bottom, playerVM.isFullscreen ? 30 : 10)
        }
    }
    
    // 格式化时间
    private func formattedTime(_ seconds: Double) -> String {
        guard !seconds.isNaN else { return "00:00" }
        
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // 格式化点赞数
    private func formatLikeCount(_ count: Int) -> String {
        if count >= 10000 {
            let formattedCount = count / 10000
            return "\(formattedCount)万"
        } else {
            return "\(count)"
        }
    }
}

// 自定义视频播放器视图，隐藏系统控件
struct CustomVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false // 隐藏系统控件
        controller.videoGravity = .resizeAspect
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // 更新逻辑
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
