//
//  SceneDelegate.swift
//  VoiceRecorder
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            let vc = HomeViewController()
            NetworkMonitor.shared.startMonitoring{ error in
                DispatchQueue.main.async {
                    Alert.present(title: nil,
                                  message: error.localizedDescription,
                                  actions: .ok({exit(0)}),
                                  from: vc)
                }
            }
            let nav = UINavigationController(rootViewController: vc)
            self.window?.backgroundColor = .systemBackground
            self.window?.rootViewController = nav
            NetworkMonitor.shared.stopMonitoring()
        }
        window?.makeKeyAndVisible()
    }
}

