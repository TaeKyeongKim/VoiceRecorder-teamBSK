//
//  File.swift
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
//    var audioPlayer: AudioPlayer?
    var currTime: Observable<AudioRecorderTime> = Observable(.zero)
    private var url: URL?
    var timer: Timer?
    var isPlaying: Observable<Bool> = Observable(false)
    var index: Observable<Int> = Observable(0)
    var averagePowerList: Observable<[CGFloat]> = Observable([])
    
    func setAudioRecorder(){
        audioRecorder =  AudioRecorder()
    }
    
    func setData() {
        guard let audioRecorder = audioRecorder else { return }
        audioRecorder.currTime.bind { val in
            self.currTime.value = val
        }
    }
    func finishRecording(){
        
    }
//    func setWavedProgress(){
//        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
//            if let audioRecorder = self.audioRecorder{
//                audioRecorder.updateMeters()
//                let db = audioRecorder.averagePower(forChannel: 0)
//                self.averagePowerList.append(CGFloat(db))
//                self.createAudioView.wavedProgressView.volumes = self.normalizeSoundLevel(level: db)
//                self.createAudioView.wavedProgressView.setNeedsDisplay()
//            }
//        }
//    }
    
    func uploadDataToStorage(totalLengthOfAudio: String,lengthOfAudio: String, data: Data, completion: @escaping (Bool) -> Void){
        let customData = CustomMetadata(length: totalLengthOfAudio)
        let storageMetadata = StorageMetadata()
        storageMetadata.customMetadata = customData.toDict()
        storageMetadata.contentType = "audio/mpeg"
        let audioInfo = AudioInfo(id: UUID().uuidString, data: data, metadata: storageMetadata)
        networkService.uploadAudio(audio: audioInfo) { error in
            if error != nil {
                print("firebase err: \(String(describing: error))")
//                self.navigationController?.popViewController(animated: true) // 수정 필요
                completion(true)
            }
//            self.navigationController?.popViewController(animated: true)
            completion(true)
        }
    }
    func setTotalPlayTimeLabel(){
//        audio = Audio(audioRecorder.url)
//        let audioLenSec = Int(audio?.audioLengthSeconds ?? 0)
//        let min = audioLenSec / 60 < 10 ? "0" + String(audioLenSec / 60) : String(audioLenSec / 60)
//        let sec = audioLenSec / 60 < 10 ? "0" + String(audioLenSec % 60) : String(audioLenSec % 60)
//        totalLenLabel.text = min + ":" + sec
    }
}


