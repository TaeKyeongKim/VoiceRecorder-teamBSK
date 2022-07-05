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
    }
    
    
    @objc private func tapRecordingButton() {
//        AVFAudio.AVAudioEngine.audioUnit.AVAudioUnit.AVAudioUnitEQFilterParameters.frequency
//        let a = AVAudioEngine()
//        let eq = AVAudioUnitEQ(numberOfBands: 1)
//        let filterParams = eq.bands[0] as AVAudioUnitEQFilterParameters
//        filterParams.filterType = .lowPass
//        filterParams.frequency = 100.0
//        filterParams.bypass = false
//        a.attach(eq)
        
        if createAudioView.recordingButton.isSelected{
            createAudioView.recordingButton.isSelected = false
            audioRecorder?.stop()
            createAudioView.buttons.playButton.isEnabled = true
            createAudioView.buttons.backButton.isEnabled = true
            createAudioView.buttons.forwordButton.isEnabled = true
            audio = Audio(audioRecorder!.url)
            if let audio = audio{
                let audioLenSec = Int(audio.audioLengthSeconds)
                createAudioView.totalLenLabel.text = "\(audioLenSec / 60):\(audioLenSec % 60)"
            }
        }else{
            createAudioView.recordingButton.isSelected = true
            createAudioView.buttons.playButton.isEnabled = false
            createAudioView.buttons.backButton.isEnabled = false
            createAudioView.buttons.forwordButton.isEnabled = false
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
        guard let audioRecorder = audioRecorder else { return }
        do {
            let data = try Data(contentsOf: audioRecorder.url)
            let storageMetadata = StorageMetadata()
            storageMetadata.contentType = "audio/mpeg"
            let audioInfo = AudioInfo(id: "UUID()", data: data, metadata: storageMetadata)
            FirebaseService.uploadAudio(audio: audioInfo) { err in
                print("firebase err: \(err)")
            }
        } catch {
            print("error: \(error.localizedDescription)")
        }
        self.navigationController?.popViewController(animated: true)
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
        print("error: \(error.localizedDescription)")
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
}



