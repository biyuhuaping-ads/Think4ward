import SwiftUI
import AppLovinSDK

@main
struct Think4wardApp: App {
    let initConfig = ALSdkInitializationConfiguration(sdkKey: "LNR7IqQoTN_ruXr55ZWa_0SoWtyL65IFWSneUVVlGsv6RXs6idmUqtaf7AilM7UX_9NOyitGTFk_0prZ75JyhZ") { builder in
        builder.mediationProvider = ALMediationProviderMAX
    }
    
    // Initialize the SDK with the configuration
    ALSdk.shared().initialize(with: initConfig) { sdkConfig in
        // Start loading ads
    }
    
    var body: some Scene {
        WindowGroup {
            DashboardView()
        }
    }
}
