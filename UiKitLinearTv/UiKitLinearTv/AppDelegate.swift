import UIKit
import SwiftUI
import FlowerSdk

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // TODO GUIDE: initialize SDK
        // env must be one of local, dev, prod
        FlowerSdk.setEnv(env: "local")
        FlowerSdk.doInit()
        // Log level must be one of Verbose, Debug, Info, Warn, Error, Off
        FlowerSdk.setLogLevel(level: "Verbose")

        window = UIWindow(frame: UIScreen.main.bounds)

        let rootViewController = RootViewController()
        let flowerRootViewController = UIHostingController(rootView: FlowerSdk.root)
        rootViewController.addChild(flowerRootViewController)
        rootViewController.view.addSubview(flowerRootViewController.view)
        flowerRootViewController.didMove(toParent: rootViewController)

        window?.rootViewController = UINavigationController(rootViewController: rootViewController)
        window?.makeKeyAndVisible()

        return true
    }
}
