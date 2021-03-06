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
        let provider = ServiceProvider.resolve()
        let searchVC = SearchViewController()
        let searchVM = SearchViewModel(title: "Search",
                                       placeHolder: "Name...",
                                       provider: provider)
        searchVC.viewModel = searchVM
        
        let searchNC = UINavigationController(rootViewController: searchVC)
        searchNC.tabBarItem.image = {
            let config = UIImage
                .SymbolConfiguration(pointSize: 15.0,
                                     weight: .regular,
                                     scale: .large)
            return UIImage(systemName: "magnifyingglass",
                           withConfiguration: config)
        }()
        
        let bookmarksVM = BookmarksViewModel(title: "Bookmarks",
                                             placeHolder: "Name...",
                                             provider: provider)
        let bookmarksVC = BookmarksViewController()
        bookmarksVC.viewModel = bookmarksVM

        let bookmarksNC = UINavigationController(rootViewController: bookmarksVC)
        bookmarksNC.tabBarItem.image = {
            let config = UIImage
                .SymbolConfiguration(pointSize: 15.0,
                                     weight: .regular,
                                     scale: .large)
            return UIImage(systemName: "bookmark",
                           withConfiguration: config)
        }()
        
        let tc = MainTabbarController()
        tc.viewControllers = [searchNC, bookmarksNC]
        return tc
    }
}
