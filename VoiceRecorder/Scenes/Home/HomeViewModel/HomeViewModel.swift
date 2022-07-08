//
//  HomeViewModel.swift
//  VoiceRecorder
//
//  Created by Kai Kim on 2022/07/01.
//

import Foundation

final class HomeViewModel {
  
  private (set) var audioTitles: [String] = [] {
    didSet{
      self.audioTitles.forEach({
        self.audioData.updateValue(
          Observable<AudioPresentation>(
            AudioPresentation(
              filename: nil,
              createdDate: nil,
              length: nil
            )
          ),
          forKey: $0
        )
      })
    }
  }
  private var audioPresentation: [AudioPresentation] = []
  private (set) var audioData: [String: Observable<AudioPresentation>] = [:]
  private var networkService: NetworkServiceable
  var errorHandler : ((Error) -> Void)?
  
  init(networkSerivce: NetworkServiceable = Firebase()) {
    self.networkService = networkSerivce
  }
  
  subscript(_ indexPath: IndexPath) -> AudioPresentation? {
    guard !audioTitles.isEmpty else {return nil}
    let title = audioTitles[indexPath.item]
    guard let data = audioData[title]?.value else {return nil}
    return data
  }
  
  func fetchAudioTitles(completion: @escaping () -> Void) {
    networkService.fetchAll { [weak self] result in
      switch result {
      case .success(let data):
        self?.audioTitles = data
        completion()
      case .failure(let error):
        self?.errorHandler?(error)
      }
    }
  }
  
  func fetchMetaData(completion: @escaping () -> Void){
    let group = DispatchGroup()
    DispatchQueue.global().async {
      self.audioTitles.forEach({
        group.enter()
        let endPoint = EndPoint(fileName: $0)
        self.networkService.featchMetaData(endPoint: endPoint) {[weak self] result in
          switch result {
          case .success(let metadata):
            self?.audioPresentation.append(metadata)
          case .failure(let error):
            self?.errorHandler?(error)
          }
          group.leave()
        }
      })
      group.notify(queue: .main) {
        self.sortByDate()
        completion()
      }
    }
  }
  
  func sortByDate() {
    self.audioTitles = self.audioTitles.sorted(by: { (val1, val2) in
      guard let index1 = self.audioPresentation.firstIndex(where: {$0.filename == val1})
      else {
        return false
      }
      guard let index2 = self.audioPresentation.firstIndex(where: {$0.filename == val2})
      else {
        return false
      }
      return self.audioPresentation[index1].createdDate?.compare(
        self.audioPresentation[index2].createdDate ?? Date()) == .orderedDescending
    })
    self.audioTitles.forEach({ title in
      guard let index = audioPresentation.firstIndex(
        where: {$0.filename == title})  else {return}
      self.audioData[title]?.value = audioPresentation[index]
    })
  }
  
  func enquireForURL(
    _ audioRepresentation: AudioPresentation,
    completion: @escaping (URL?) -> Void) {
      guard let fileName = audioRepresentation.filename else {return}
      let endPoint = EndPoint(fileName: fileName)
      networkService.makeURL(endPoint: endPoint) { result in
        switch result {
        case .success(let url):
          completion(url)
        case .failure(let error):
          self.errorHandler?(error)
        }
      }
    }
  
  func remove(indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
    let title = audioTitles[indexPath.item]
    let audioInfo = AudioInfo(id: title, data: nil, metadata: nil)
    networkService.delete(audio: audioInfo) { [weak self] error in
      if let error = error as? NSError {
        print(error)
        completion(false)
        self?.errorHandler?(error)
      }else{
        self?.audioTitles.remove(at: indexPath.item)
        self?.audioPresentation.remove(at: indexPath.item)
        self?.audioData.removeValue(forKey: title)
        completion(true)
      }
    }
  }
  
  
  func reset(){
    audioTitles.removeAll()
    audioPresentation.removeAll()
    audioData.removeAll()
  }
  
}
