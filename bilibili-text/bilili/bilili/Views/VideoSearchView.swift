import SwiftUI

struct VideoSearchView: View {
    @ObservedObject var viewModel: VideoViewModel
    @State private var searchText = ""
    @State private var searchResults: [Video] = []
    @State private var isSearching = false
    @FocusState private var isSearchFieldFocused: Bool
    
    // 通过环境变量获取当前视图的返回模式
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        VStack {
            // 搜索结果列表
            if !searchText.isEmpty {
                if searchResults.isEmpty && !isSearching {
                    // 无搜索结果提示
                    VStack {
                        Image(systemName: "exclamationmark.magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                            .padding()
                        Text("没有找到匹配的视频")
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(searchResults) { video in
                            VideoRowItemlView(video: video)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            } else {
                // 无搜索内容时的占位视图
                VStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                        .padding()
                    Text("输入关键词搜索视频")
                        .foregroundColor(.gray)
                }
                .frame(maxHeight: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // 左侧返回按钮
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button(action: {
//                    // 调用 presentationMode 来返回上一级视图
//                    presentationMode.wrappedValue.dismiss()
//                }) {
//                    Image(systemName: "chevron.left")
//                }
//            }
            
            // 中间搜索栏
            ToolbarItem(placement: .principal) {
                HStack {
                    TextField("搜索视频...", text: $searchText, onCommit: performSearch)
                        .focused($isSearchFieldFocused)
                        .padding(8)
                        .padding(.horizontal, 24)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 8)
                                
                                if !searchText.isEmpty {
                                    Button(action: {
                                        searchText = ""
                                    }) {
                                        Image(systemName: "multiply.circle.fill")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 8)
                                    }
                                }
                            }
                        )
                        .frame(maxWidth: .infinity)
                }
            }
            
            // 右侧搜索按钮
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: performSearch) {
                    Text("搜索")
                }
                .disabled(searchText.isEmpty)
            }
        }
    }
    
    private func performSearch() {
        // 清空之前的搜索结果
        searchResults = []
        isSearching = true
        
        // 模拟搜索延迟（实际项目中可以去掉）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // 执行搜索并更新结果
            searchResults = viewModel.searchVideos(byTitle: searchText)
            isSearching = false
            isSearchFieldFocused = false // 隐藏键盘
        }
    }
}
