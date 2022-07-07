//
//  LoadingIndicator.swift
//  VoiceRecorder
//
//  Created by Bran on 2022/07/04.
//

import UIKit

class LoadingIndicator {
  static func showLoading() {
    print(#function)
    guard let window = UIApplication.shared.windows.last else { return }

    let loadingIndicatorView: UIActivityIndicatorView
    if let existedView = window.subviews.first(where: { $0 is UIActivityIndicatorView } ) as? UIActivityIndicatorView {
      loadingIndicatorView = existedView
    } else {
      loadingIndicatorView = UIActivityIndicatorView(style: .large)
      loadingIndicatorView.frame = window.frame
      loadingIndicatorView.backgroundColor = .white
      loadingIndicatorView.color = .brown
      window.addSubview(loadingIndicatorView)
    }
    loadingIndicatorView.startAnimating()
  }

  static func hideLoading() {
    print(#function)
    DispatchQueue.main.async {
      guard let window = UIApplication.shared.windows.last else { return }
      window.subviews.filter({ $0 is UIActivityIndicatorView }).forEach { $0.removeFromSuperview() }
    }
  }
}
