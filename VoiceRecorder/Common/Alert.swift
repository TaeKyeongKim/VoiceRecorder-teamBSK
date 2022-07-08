//
//  Alert.swift
//  VoiceRecorder
//
//  Created by Kai Kim on 2022/07/07.
//

import Foundation
import UIKit

struct Alert {
    
    static func present(title: String?, message: String, actions: Alert.Action..., from controller: UIViewController){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach({
            alertController.addAction($0.alertAction)
        })
        controller.present(alertController, animated: true)
    }
}

extension Alert {
    
    typealias handler = (()->Void)?
    
    enum Action{
        case ok (handler)
        case cancel
        
        private var title: String {
            switch self {
            case .ok:
                return "확인"
            case .cancel:
                return "취소"
            }
        }
        
        private var completion: handler {
            switch self {
            case .ok(let handler):
                return handler
            case .cancel:
                return nil
            }
        }
        
        var alertAction: UIAlertAction {
            return UIAlertAction(title: title, style: .default) { _ in
                if let handler = self.completion {
                    handler()
                }
            }
        }
    }
}
