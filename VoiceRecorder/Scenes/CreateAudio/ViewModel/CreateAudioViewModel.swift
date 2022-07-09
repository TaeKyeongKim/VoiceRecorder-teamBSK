//
//  CreateAudioViewModel.swift
//  VoiceRecorder
//
//  Created by dong eun shin on 2022/07/09.
//

import Foundation

import AVFoundation

import FirebaseStorage

class CreateAudioViewModel{
    private var networkService: NetworkServiceable = Firebase()
    var audioRecorder: AudioRecorder?
    var currTime: Observable<AudioRecorderTime> = Observable(.zero)
    
    func setAudioRecorder(){
        audioRecorder =  AudioRecorder()
    }
    func setData() {
        guard let audioRecorder = audioRecorder else { return }
        audioRecorder.currTime.bind { val in
            self.currTime.value = val
        }
    }
    func uploadDataToStorage(lengthOfAudio: String, data: Data, completion: @escaping (Bool) -> Void){
        let customData = CustomMetadata(length: lengthOfAudio)
        let storageMetadata = StorageMetadata()
        storageMetadata.customMetadata = customData.toDict()
        storageMetadata.contentType = "audio/mpeg"
        let audioInfo = AudioInfo(id: UUID().uuidString, data: data, metadata: storageMetadata)
        networkService.uploadAudio(audio: audioInfo) { error in
            if error != nil {
                print("ERROR: \(String(describing: error))")
                completion(true)
            }
            completion(true)
        }
    }
}
