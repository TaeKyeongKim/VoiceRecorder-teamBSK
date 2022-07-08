//
//  TimeFormatter.swift
//  VoiceRecorder
//
//  Created by Kai Kim on 2022/07/01.
//

import Foundation

class MyDateFormatter {

    static let shared = MyDateFormatter()

    private init() {}

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()

    func dateToString(from date: Date) -> String {
        dateFormatter.string(from: date)
    }

}
