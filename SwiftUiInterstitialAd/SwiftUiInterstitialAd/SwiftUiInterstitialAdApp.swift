import SwiftUI
import FlowerSdk

@main
struct SwiftUiInterstitialAdApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                FlowerSdk.root
            }
        }
    }

    init() {
        // TODO GUIDE: initialize SDK
        // env must be one of local, dev, prod
        FlowerSdk.setEnv(env: "local")
        FlowerSdk.doInit()
        // Log level must be one of Verbose, Debug, Info, Warn, Error, Off
        FlowerSdk.setLogLevel(level: "Verbose")
    }
}
