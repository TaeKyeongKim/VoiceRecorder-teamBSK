//
//  NetworkMonitor.swift
//  VoiceRecorder
//
//  Created by Kai Kim on 2022/07/07.
//

import Foundation
import Network

final class NetworkMonitor {
    
    static var shared = NetworkMonitor()
    
    private init () {}
    
    let monitor = NWPathMonitor()
    
    func startMonitoring(completion: @escaping () -> Void) {
        monitor.start(queue: .global())
        monitor.pathUpdateHandler = { path in
            if path.status == .unsatisfied {
                completion()
            }
        }
    }
    
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
}
