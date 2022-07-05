//
//  ViewController.swift
//  VoiceRecorder
//
//  Created by dong eun shin on 2022/06/29.
//

import UIKit

import AVFoundation

import FirebaseStorage

class CreateAudioViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {

    let createAudioView = CreateAudioView()
    var audio: Audio?
    
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    
    @objc private func tapRecordingButton() {
        if createAudioView.recordingButton.isSelected{
            bottonsToggle(true)
            audioRecorder?.stop()
            setTotalPlayTimeLabel()
        }else{
            bottonsToggle(false)
            self.record()
        }
    }
    @objc
    private func playButtonClicked() {
        audio?.playOrPause()
    }
    @objc
    func backButtonclicked() {
        guard audio != nil else { return }
        audio?.skip(forwards: false)
    }
    @objc
    func forwardButtonClicked() {
      guard audio != nil else { return }
      audio?.skip(forwards: true)
    }
    @objc
    func tapDoneButton() {
        guard let audioRecorder = audioRecorder else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        do {
            let data = try Data(contentsOf: audioRecorder.url)
            uploadDataToStorage(data: data)
        } catch {
            print("error: \(error.localizedDescription)")
            self.navigationController?.popViewController(animated: true) // 수정 필요
        }
    }
    func config() {
        createAudioView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createAudioView)
        NSLayoutConstraint.activate([
        createAudioView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
        createAudioView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        createAudioView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        createAudioView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        createAudioView.recordingButton.addTarget(
          self,
          action: #selector(tapRecordingButton),
          for: .touchUpInside
        )
        createAudioView.buttons.backButton.addTarget(
          self,
          action: #selector(backButtonclicked),
          for: .touchUpInside
        )
        createAudioView.buttons.playButton.addTarget(
          self,
          action: #selector(playButtonClicked),
          for: .touchUpInside
        )
        createAudioView.buttons.forwordButton.addTarget(
          self,
          action: #selector(forwardButtonClicked),
          for: .touchUpInside
        )
        createAudioView.doneButton.addTarget(
          self,
          action: #selector(tapDoneButton),
          for: .touchUpInside
        )
    }
    func record() {
      let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("fileName.m4a")
      let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
      ]
      
      do {
        try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
      } catch {
        print("error: \(error.localizedDescription)") // alert??
      }
      
      do {
        self.audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
          self.audioRecorder?.delegate = self
          self.audioRecorder?.record()
      } catch {
        print("error: \(error.localizedDescription)")
          self.audioRecorder?.stop()
      }
    }
    
    func setTotalPlayTimeLabel(){
        if let audioRecorder = audioRecorder{
            audio = Audio(audioRecorder.url)
            let audioLenSec = Int(audio?.audioLengthSeconds ?? 0)
            let min = audioLenSec / 60 < 10 ? "0" + String(audioLenSec / 60) : String(audioLenSec / 60)
            let sec = audioLenSec / 60 < 10 ? "0" + String(audioLenSec % 60) : String(audioLenSec % 60)
            self.createAudioView.totalLenLabel.text = min + ":" + sec
        }
    }
    
    func bottonsToggle(_ bool: Bool){
        createAudioView.recordingButton.isSelected = !bool
        createAudioView.doneButton.isEnabled = bool
        createAudioView.buttons.playButton.isEnabled = bool
        createAudioView.buttons.backButton.isEnabled = bool
        createAudioView.buttons.forwordButton.isEnabled = bool
    }
    
    func uploadDataToStorage(data: Data){
        let customData = CustomMetadata(length: createAudioView.totalLenLabel.text ?? "00:00")
        let storageMetadata = StorageMetadata()
        storageMetadata.customMetadata = customData.toDict()
        storageMetadata.contentType = "audio/mpeg"
        let audioInfo = AudioInfo(id: UUID().uuidString, data: data, metadata: storageMetadata)
        FirebaseService.uploadAudio(audio: audioInfo) { result in
            switch result {
            case .success(_):
                self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                print("firebase err: \(error)")
                self.navigationController?.popViewController(animated: true) // 수정 필요
            }
        }
    }
}



//        AVFAudio.AVAudioEngine.audioUnit.AVAudioUnit.AVAudioUnitEQFilterParameters.frequency
//        let a = AVAudioEngine()
//        let eq = AVAudioUnitEQ(numberOfBands: 1)
//        let filterParams = eq.bands[0] as AVAudioUnitEQFilterParameters
//        filterParams.filterType = .lowPass
//        filterParams.frequency = 100.0
//        filterParams.bypass = false
//        a.attach(eq)
