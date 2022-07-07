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
    case lostConnection
    
    var errorDescription: String? {
 
        switch self {
        case .firebaseError(let error):
            switch StorageErrorCode(rawValue: error.code) {
            case .objectNotFound:
                return "파일이 존재하지 않습니다. 새로 고침 해주세요."
            case .bucketNotFound:
                return "참조 대상을 찾을수 없습니다. 앱을 다시 설치 해주세요."
            case .quotaExceeded:
                 return "저장공간이 부족합니다, 녹음파일 정리 혹은 서비스 를 업그레이드 해주세요."
            default:
                return "알수 없는 에러가 발생했습니다. 앱을 다시 실행 시켜주세요."
            }
        case .lostConnection:
            return "서버에 연결할 수 없습니다. 인터넷 연결상태를 확인해주세요."
        }
    }
}
