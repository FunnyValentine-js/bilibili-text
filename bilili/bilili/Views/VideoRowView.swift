import SwiftUI

struct VideoRowView: View {
    @StateObject private var viewModel = VideoViewModel(
        databasePath: NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        ).first! + "/videos.db"
    )
    
    private let columns = [
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(viewModel.videos) { video in
                        VideoRowItemlView(video: video)
                    }
                }
                .padding()
                
                // 底部加载视图
                if viewModel.isShowingLoader || viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .transition(.opacity)
                } else {
                    // 底部空间，用于检测滚动到底部
                    GeometryReader { geometry in
                        Color.clear
                            .frame(height: 1)
                            .onAppear {
                                viewModel.handleScrollToBottom()
                            }
                    }
                    .frame(height: 1)
                }
            }
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geometry.frame(in: .named("scrollView")).minY
                        )
                }
            )
            .coordinateSpace(name: "scrollView")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                viewModel.handleScrollOffsetChange(value)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.loadInitialData()
        }
    }
}
