//
//  SceneDelegate.swift
//  VoiceRecorder
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        window.makeKeyAndVisible()

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            let vc = HomeViewController()
            let nav = UINavigationController(rootViewController: vc)
            window.backgroundColor = .systemBackground
            window.rootViewController = nav
            window.makeKeyAndVisible()
            NetworkMonitor.shared.startMonitoring{ error in
                DispatchQueue.main.async {
                    Alert.present(title: nil,
                                  message: error.localizedDescription,
                                  actions: .ok({exit(0)}),
                                  from: vc)
                }
            }
            NetworkMonitor.shared.stopMonitoring()
        }
        self.window = window
    }
}

