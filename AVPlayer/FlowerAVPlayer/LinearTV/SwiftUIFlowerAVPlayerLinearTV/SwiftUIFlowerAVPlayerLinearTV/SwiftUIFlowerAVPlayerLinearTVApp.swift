import SwiftUI
import FlowerSdk

@main
struct SwiftUIFlowerAVPlayerLinearTVApp: App {
    var body: some Scene {
        WindowGroup {
            PlaybackView()
        }
    }

    init() {
        // TODO GUIDE: Initialize SDK
        // env must be one of local, dev, prod
        FlowerSdk.setEnv(env: "local")
        FlowerSdk.doInit()
        // Log level must be one of Verbose, Debug, Info, Warn, Error, Off
        FlowerSdk.setLogLevel(level: "Debug")
    }
}
