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

    private var networkService: NetworkServiceable = Firebase()
    let createAudioView = CreateAudioView()
    var audio: Audio?
    var timer: Timer?
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var arr: [CGFloat] = []
    var currTime: Double = 0.0
    var i: Int = 0
    var isPlaying = false
    let firstPoint = CGPoint(x: 0.0, y: 0.0)
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    
    @objc private func tapRecordingButton() {
        if createAudioView.recordingButton.isSelected{
            bottonsToggle(true)
            timer?.invalidate()
            audioRecorder?.stop()
            setTotalPlayTime()
            createAudioView.wavedProgressView.scrollLayer.scroll(self.firstPoint)
            self.createAudioView.wavedProgressView.translation = 0
            initAudioPlayer()
        }else{
            bottonsToggle(false)
            self.record()
        }
    }
    @objc
    private func playButtonClicked() {
//        audio?.playOrPause()
        if isPlaying == true{
            print("pause")
            audioPlayer?.pause()
            timer?.invalidate()
        }else{
            print("play-----------")
            print(self.createAudioView.wavedProgressView.translation, self.createAudioView.wavedProgressView.xOffset)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                print("currTime:", self.audioPlayer!.currentTime)
                if self.arr.count > self.i{
                    self.createAudioView.wavedProgressView.scrollLayerScroll()
                    self.i += 1
                }else{
                    timer.invalidate()
                    self.i = 0
                    self.isPlaying.toggle()
                    self.createAudioView.wavedProgressView.translation = 0
                    self.createAudioView.wavedProgressView.scrollLayer.scroll(self.firstPoint)
                }
            }
        }
        isPlaying.toggle()
    }
    @objc
    func backButtonclicked() {
//        guard audio != nil else { return }
//        audio?.skip(forwards: false)
        //
        print("back------------",self.i)
        if Double(audioPlayer!.currentTime) < 5 {
            self.audioPlayer?.currentTime = TimeInterval(0.0)
            self.i = 0
            self.createAudioView.wavedProgressView.translation = 0
            self.createAudioView.wavedProgressView.scrollLayer.scroll(self.firstPoint)
        } else {
            self.audioPlayer?.currentTime = TimeInterval(audioPlayer!.currentTime - 5)
            self.i -= 50
            self.createAudioView.wavedProgressView.translation -= 50 * 3
            let newPoint = CGPoint(x: self.createAudioView.wavedProgressView.translation, y: 0.0)
            self.createAudioView.wavedProgressView.scrollLayer.scroll(newPoint)
        }
        print(self.i, self.arr.count)
        print(self.createAudioView.wavedProgressView.translation)
        print("------------")
    }
    @objc
    func forwardButtonClicked() {
//      guard audio != nil else { return }
//      audio?.skip(forwards: true)
        print("forward------------",self.i)
        if Double(audioPlayer!.currentTime + 5) >= Double(audioPlayer!.duration) {
            self.audioPlayer?.currentTime = TimeInterval(audioPlayer!.duration)
            timer?.invalidate()
            self.i = 0
            self.isPlaying.toggle()
            self.createAudioView.wavedProgressView.translation = 0
            self.createAudioView.wavedProgressView.scrollLayer.scroll(self.firstPoint)
        } else {
            self.audioPlayer?.currentTime = TimeInterval(audioPlayer!.currentTime + 5)
            self.i += 50
            self.createAudioView.wavedProgressView.translation += 50 * 3
            let newPoint = CGPoint(x: self.createAudioView.wavedProgressView.translation, y: 0.0)
            self.createAudioView.wavedProgressView.scrollLayer.scroll(newPoint)
        }
        print(self.i, self.arr.count)
        print(self.createAudioView.wavedProgressView.translation)
        print("------------")
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
        AVSampleRateKey: 44100,
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
        self.audioRecorder?.isMeteringEnabled = true // ?
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if let audioRecorder = self.audioRecorder{
                audioRecorder.updateMeters()
                let db = audioRecorder.averagePower(forChannel: 0)
                self.arr.append(CGFloat(db))
                self.createAudioView.wavedProgressView.volumes = self.normalizeSoundLevel(level: db)
                self.createAudioView.wavedProgressView.setNeedsDisplay()
            }
        }
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
        networkService.uploadAudio(audio: audioInfo) { error in
            if error != nil {
                print("firebase err: \(error)")
                self.navigationController?.popViewController(animated: true) // 수정 필요
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        let lowLevel: Float = -50
        let highLevel: Float = -10
        
        var level = max(0.0, level - lowLevel)
        level = min(level, highLevel - lowLevel)
        return CGFloat(Float(level / (highLevel - lowLevel)))
    }
    func initAudioPlayer() {
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: audioRecorder!.url)
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
    
    func setTotalPlayTime(){
        if let audioRecorder = audioRecorder{
            audio = Audio(audioRecorder.url)
            let audioLenSec = Int(audio?.audioLengthSeconds ?? 0)
            let min = audioLenSec / 60 < 10 ? "0" + String(audioLenSec / 60) : String(audioLenSec / 60)
            let sec = audioLenSec % 60 < 10 ? "0" + String(audioLenSec % 60) : String(audioLenSec % 60)
            self.createAudioView.totalLenLabel.text = min + ":" + sec
        }
        self.createAudioView.totalLenLabel.isHidden = false
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
