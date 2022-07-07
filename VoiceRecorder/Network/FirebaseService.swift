//
//  Services.swift
//  VoiceRecorder
//
//  Created by Kai Kim on 2022/06/29.
//

import Foundation

import FirebaseStorage

//protocol Firebase {
//    func fetchAll(completion: @escaping (Result <StorageListResult, StorageError>) -> Void)
//    func makeURL(endPoint: EndPoint, completion: @escaping (Result <URL, StorageError>) -> Void)
//    func featchMetaData(endPoint: EndPoint, completion: @escaping (Result <StorageMetadata, StorageError>) -> Void)
//    func uploadAudio(audio: AudioInfo, completion: @escaping (Result <StorageMetadata, StorageError>) -> Void)
//    func delete(audio: AudioInfo, completion: @escaping (StorageError?) -> Void)
//}

enum FirebaseService {
    
    static func fetchAll(completion: @escaping (Result <StorageListResult, Error>) -> Void) {
        
        EndPoint.reference.listAll { result, error in
            if let error = error as? NSError {
                completion(.failure(NetworkError.firebaseError(error)))
                return
            }
            guard let result = result else {return}
            completion(.success(result))
            return
        }
        
    }
    
    static func makeURL(endPoint: EndPoint, completion: @escaping (Result <URL, Error>) -> Void)  {
        
        endPoint.path.downloadURL{ url, error in
            if let error = error as? NSError {
                completion(.failure(NetworkError.firebaseError(error)))
                return
            }
            guard let url = url else {return}
            completion(.success(url))
            return
        }
    }
    
    
    static func featchMetaData(endPoint: EndPoint, completion: @escaping (Result <StorageMetadata, Error>) -> Void) {
        
        endPoint.path.getMetadata { result in
            switch result {
            case .success(let metaData):
                completion(.success(metaData))
            case .failure(let error):
                completion(.failure(NetworkError.firebaseError(error as NSError)))
            }
        }
    }
    
    static func uploadAudio(audio: AudioInfo, completion: @escaping (Result <StorageMetadata, Error>) -> Void) {
        
        let endPoint = EndPoint(fileName: audio.id)
        guard let data = audio.data, let metadata = audio.metadata else {return}
        endPoint.path.putData(data, metadata: metadata){ result in
            switch result {
            case .success(let metaData):
                completion(.success(metaData))
            case .failure(let error):
                completion(.failure(NetworkError.firebaseError(error as NSError)))
                
            }
        }
    }
    
    static func delete(audio: AudioInfo, completion: @escaping (Error?) -> Void) {
        
        let endPoint = EndPoint(fileName: audio.id)
        endPoint.path.delete { error in
            if let error = error as? NSError {
                completion((NetworkError.firebaseError(error)))
                return
            }else{
                completion(nil)
                return
            }
        }
    }
}
