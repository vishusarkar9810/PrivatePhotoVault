//
//  SceneDelegate.swift
//  PrivatePhotoVault
//
//  Created by Vishwajeet Sarkar on 06/03/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    // Temporarily disabled to use AppDelegate setup
    /*
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("SceneDelegate: scene will connect at \(Date())")
        guard let windowScene = (scene as? UIWindowScene) else {
            print("SceneDelegate: Failed to cast scene to UIWindowScene")
            return
        }
        window = UIWindow(windowScene: windowScene)
        if window == nil {
            print("SceneDelegate: Window creation failed")
            return
        }
        
        let navController = UINavigationController(rootViewController: PasscodeViewController())
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        print("SceneDelegate: Window made key and visible at \(Date()) with root: \(String(describing: window?.rootViewController))")
        
        DispatchQueue.main.async {
            navController.view.setNeedsLayout()
            navController.view.layoutIfNeeded()
        }
    }
    */
}
