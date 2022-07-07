//
//  NetworkError.swift
//  VoiceRecorder
//
//  Created by Kai Kim on 2022/07/07.
//

import Foundation

import FirebaseStorage

enum NetworkError: Error, LocalizedError {
    case firebaseError(NSError)
    
    var errorDescription: String? {
        let defaultMessage = "앱 을 다시 실행시켜주세요"
        switch self {
        case .firebaseError(let error):
            switch StorageErrorCode(rawValue: error.code) {
            case .objectNotFound:
                return "파일이 존재하지 않습니다" + defaultMessage
            case .bucketNotFound:
                return "참조 대상을 찾을수 없습니다" + defaultMessage
            case .quotaExceeded:
                 return "저장공간이 부족합니다, 녹음파일 정리 혹은 서비스 를 업그레이드 해주세요"
            default:
                return defaultMessage
            }
        }
    }
}
