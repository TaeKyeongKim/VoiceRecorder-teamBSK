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
    let vc = HomeViewController()
    let nav = UINavigationController(rootViewController: vc)
    window.backgroundColor = .systemBackground
    window.rootViewController = nav
    window.makeKeyAndVisible()
    self.window = window
  }
}

