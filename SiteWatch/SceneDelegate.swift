//
//  SceneDelegate.swift
//  SiteWatch
//
//  Created by Simon Kim on 2023/03/14.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    var isUnitTesting: Bool {
      return ProcessInfo.processInfo.arguments.contains("-UNITTEST")
    }
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard !isUnitTesting else { return }
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)

        let logger = DemoAppLogger()
        let server = SimulatedServer(logger: logger)

        let homeScene = SitesScene(
            remoteServer: server,
            imageStore: CachedImageStore(),
            logger: logger
        )
        
        window.rootViewController = homeScene.viewController()
        window.makeKeyAndVisible()
        self.window = window
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }


}

