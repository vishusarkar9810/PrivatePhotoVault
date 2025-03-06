//
//  AppDelegate.swift
//  PrivatePhotoVault
//
//  Created by Vishwajeet Sarkar on 06/03/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("AppDelegate: didFinishLaunchingWithOptions at \(Date())")
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white // Ensure window has a visible background
        
        let rootVC = PasscodeViewController()
        let navController = UINavigationController(rootViewController: rootVC)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        
        print("AppDelegate: Window set with root: \(String(describing: window?.rootViewController))")
        
        // Force layout to ensure UI renders
        DispatchQueue.main.async {
            navController.view.setNeedsLayout()
            navController.view.layoutIfNeeded()
        }
        
        return true
    }

    // Disable state restoration for now
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return false
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return false
    }
}
