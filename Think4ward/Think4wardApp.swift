import SwiftUI
import AppLovinSDK
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct Think4wardApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var showAdPage = false

    init() {
        let initConfig = ALSdkInitializationConfiguration(sdkKey: "LNR7IqQoTN_ruXr55ZWa_0SoWtyL65IFWSneUVVlGsv6RXs6idmUqtaf7AilM7UX_9NOyitGTFk_0prZ75JyhZ") { builder in
            builder.mediationProvider = ALMediationProviderMAX
        }

        ALSdk.shared().initialize(with: initConfig) { sdkConfig in
            print("AppLovin SDK initialized.")
            // 可以在这里预加载广告，例如 Interstitials
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if showAdPage {
                AdLaunchView()
            } else {
                DashboardView()
                    .onOpenURL { url in
                        handleIncomingURL(url)
                    }
            }
        }
    }
    
    // 通用的URL处理方法：Think4ward://page?name=AppLovin
    private func handleIncomingURL(_ url: URL) {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems,
           queryItems.contains(where: { $0.name == "name" && $0.value == "AppLovin" }) {
            print("接收到链接: \(url.absoluteString)")
            print("queryItems: \(queryItems)")
            print("Path: \(url.path)")
            showAdPage = true
        }
    }
}
