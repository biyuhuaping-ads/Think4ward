//
//  InterstitialAdVC.swift
//  Think4ward
//
//  Created by ZB on 2025/5/7.
//
import UIKit
import AppLovinSDK

class InterstitialAdVC: UIViewController, MAAdDelegate {
//    static let shared = InterstitialAdVC()
    static let shared: InterstitialAdVC = {
        let instance = InterstitialAdVC()
        instance.createInterstitialAd() // 自动初始化广告
        return instance
    }()
    var onAdClick: (() -> Void)?

    var interstitialAd: MAInterstitialAd!
    var retryAttempt = 0.0

    private override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        createInterstitialAd()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createInterstitialAd() {
        // 如果已经有了，就不重复创建
        if interstitialAd != nil { return }
        
        interstitialAd = MAInterstitialAd(adUnitIdentifier: "f02123778ef3074f")
        interstitialAd.delegate = self
        interstitialAd.load()
    }

    func showAdIfAvailable() {
        if interstitialAd.isReady {
            interstitialAd.show()
        } else {
            print("Ad not ready")
            interstitialAd.load()
        }
    }

    // MARK: - MAAdDelegate methods
    // 加载失败
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
//        自动重试加载广告；
//        避免频繁请求服务器（通过指数退避）；
//        最长延迟为 64 秒，防止长时间卡住逻辑。
        retryAttempt += 1
        let delay = pow(2.0, min(6.0, retryAttempt))
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.interstitialAd.load()
        }
    }
    //加载成功 5
    func didLoad(_ ad: MAAd) {
        retryAttempt = 0
        print("MAAdDelegate: didLoad")
        writeAutoStatus(to: 5)
    }
    
    //展示成功 6
    func didDisplay(_ ad: MAAd) {
        print("MAAdDelegate: didDisplay")
        writeAutoStatus(to: 6)
    }
    //展示失败 7
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        interstitialAd.load()
        print("MAAdDelegate: didFail")
        writeAutoStatus(to: 7)
    }
    
    //用户点击了广告 8
    func didClick(_ ad: MAAd) {
        print("MAAdDelegate: didClick")
        onAdClick?() // 通知外部可跳转
        writeAutoStatus(to: 8)
    }
    //广告被关闭 9
    func didHide(_ ad: MAAd) {
        print("MAAdDelegate: didHide")
        writeAutoStatus(to: 9)
        self.interstitialAd.load()//重新load广告
    }
    
    //写入文件
    func writeAutoStatus(to status: Int) {
        let path = "/var/jb/var/mobile/Documents/auto_status.json"
        let timestamp = Int(Date().timeIntervalSince1970)
        let statusInfo: [String: Any] = [
            "status": status,
            "time": timestamp
        ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: statusInfo, options: [])
            try data.write(to: URL(fileURLWithPath: path), options: .atomic)
        } catch {
            
            print("Failed to write auto_status.json: \(error)")
        }
    }
}
