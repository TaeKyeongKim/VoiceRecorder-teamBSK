//
//  Services.swift
//  VoiceRecorder
//
//  Created by Kai Kim on 2022/06/29.
//

import Foundation

import FirebaseStorage

enum FirebaseService {
    
    static func fetchAll(completion: @escaping (Result <StorageListResult, Error>) -> Void) {
        
        EndPoint.reference.listAll { result, error in
            if let error = error as? NSError {
                completion(.failure(error))
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
                completion(.failure(error))
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
                completion(.failure(error))
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
                completion(.failure(error))
            }
        }
    }
    
    static func delete(audio: AudioInfo, completion: @escaping (Error?) -> Void) {
        
        let endPoint = EndPoint(fileName: audio.id)
        endPoint.path.delete { error in
            if let error = error as? NSError {
                completion(error)
                return
            }else{
                completion(nil)
                return
            }
        }
    }
}
