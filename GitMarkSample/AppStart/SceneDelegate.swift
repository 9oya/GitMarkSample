//
//  SceneDelegate.swift
//  GitMarkSample
//
//  Created by Eido Goya on 2022/04/29.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = rootViewController()
        window?.makeKeyAndVisible()
    }

}

extension SceneDelegate {
    
    private func rootViewController() -> UIViewController {
        
        
        return UIViewController()
    }
}
