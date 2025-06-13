import SwiftUI

class StatusBarManager: ObservableObject {
    @Published var isHidden: Bool = false {
        didSet {
            print("状态栏状态改变: isHidden = \(isHidden)")
            setStatusBarHidden(isHidden)
        }
    }
    
    private func setStatusBarHidden(_ hidden: Bool) {
        print("正在设置状态栏状态: hidden = \(hidden)")
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            print("找到window，当前windowLevel: \(window.windowLevel)")
            window.windowLevel = hidden ? .statusBar + 1 : .normal
            print("设置后windowLevel: \(window.windowLevel)")
        } else {
            print("未找到window或windowScene")
        }
    }
} 