import SwiftUI
import AppLovinSDK

struct AdLaunchView: View {
    @State private var isAdLoaded = false
    private let interstitialAd = ALInterstitialAd(sdk: ALSdk.shared())

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea() // 全屏黑色背景
            VStack {
                Spacer()
                
                Button(action: {
                    showAdIfAvailable()
                }) {
                    Text("Test Button")
                        .font(.title3)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 32)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Spacer()

                Text("This page is for testing AppLovin ads only.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20) // 控制底部间距
            }
            .padding()
        }
    }
    
    private func showAdIfAvailable() {
        print("👉 加载/展示广告")
        let adVC = InterstitialAdVC.shared
        adVC.showAdIfAvailable()
    }
}
