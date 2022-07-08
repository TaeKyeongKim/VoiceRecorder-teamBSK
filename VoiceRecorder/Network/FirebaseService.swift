//
//  Services.swift
//  VoiceRecorder
//
//  Created by Kai Kim on 2022/06/29.
//

import Foundation

import FirebaseStorage

protocol NetworkServiceable {
    func fetchAll(completion: @escaping (Result <[String], Error>) -> Void)
    func makeURL(endPoint: EndPoint, completion: @escaping (Result <URL, Error>) -> Void)
    func featchMetaData(endPoint: EndPoint, completion: @escaping (Result <AudioPresentation, Error>) -> Void)
    func uploadAudio(audio: AudioInfo, completion: @escaping (Error?) -> Void)
    func delete(audio: AudioInfo, completion: @escaping (Error?) -> Void)
}

struct Firebase: NetworkServiceable {
    
    func fetchAll(completion: @escaping (Result <[String], Error>) -> Void) {
        var titleList: [String] = []
        EndPoint.reference.listAll { result, error in
            if let error = error as? NSError {
                completion(.failure(NetworkError.firebaseError(error)))
                return
            }
            guard let result = result else {return}
            result.items.forEach({
                titleList.append($0.name)
            })
            completion(.success(titleList))
            return
        }
        
    }
    
    func makeURL(endPoint: EndPoint, completion: @escaping (Result <URL, Error>) -> Void)  {
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
    
    
    func featchMetaData(endPoint: EndPoint, completion: @escaping (Result <AudioPresentation, Error>) -> Void) {
        endPoint.path.getMetadata { result in
            switch result {
            case .success(let metaData):
                completion(.success(metaData.toDomain()))
            case .failure(let error):
                completion(.failure(NetworkError.firebaseError(error as NSError)))
            }
        }
    }
    
    func uploadAudio(audio: AudioInfo, completion: @escaping (Error?) -> Void) {
        let endPoint = EndPoint(fileName: audio.id)
        guard let data = audio.data, let metadata = audio.metadata else {return}
        endPoint.path.putData(data, metadata: metadata){ result in
            switch result {
            case .success(_):
                completion(nil)
            case .failure(let error):
                completion((NetworkError.firebaseError(error as NSError)))
            }
        }
    }
    
    func delete(audio: AudioInfo, completion: @escaping (Error?) -> Void) {
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
