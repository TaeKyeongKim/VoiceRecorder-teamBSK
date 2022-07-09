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
    private var networkService: NetworkServiceable = Firebase()
    
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var timer: Timer?
    
    var arr: [CGFloat] = []
    var index: Int = 0
    var isPlaying = false
    let firstPoint = CGPoint(x: 0.0, y: 0.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationItems()
        setConstraint()
        setButtonsTarget()
    }
    func setNavigationItems(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(tapCancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tapDoneButton))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    func setConstraint() {
        createAudioView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createAudioView)
        NSLayoutConstraint.activate([
        createAudioView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
        createAudioView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        createAudioView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        createAudioView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    func setButtonsTarget(){
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
    func bottonsToggle(_ bool: Bool){
        createAudioView.recordingButton.isSelected = !bool
        createAudioView.buttons.playButton.isEnabled = bool
        createAudioView.buttons.backButton.isEnabled = bool
        createAudioView.buttons.forwordButton.isEnabled = bool
    }
    func startRecording() {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("fileName.m4a")
        let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                        AVSampleRateKey: 44100,
                        AVNumberOfChannelsKey: 1,
                        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
      
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
        } catch {
            print("error: \(error.localizedDescription)")
        }
      
        do {
            self.audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            self.audioRecorder?.delegate = self
            self.audioRecorder?.isMeteringEnabled = true
            self.audioRecorder?.record()
            self.setWavedProgress()
        } catch {
            print("error: \(error.localizedDescription)")
            self.audioRecorder?.stop()
        }
    }
    func scrollWavedProgressView(translation: CGFloat, point: CGPoint){
        self.createAudioView.wavedProgressView.translation = translation
        self.createAudioView.wavedProgressView.scrollLayer.scroll(point)
    }
    func setWavedProgress(){
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if let audioRecorder = self.audioRecorder{
                audioRecorder.updateMeters()
                let db = audioRecorder.averagePower(forChannel: 0)
                self.arr.append(CGFloat(db))
                self.createAudioView.wavedProgressView.volumes = self.normalizeSoundLevel(level: db)
                self.createAudioView.wavedProgressView.setNeedsDisplay()
            }
        }
    }
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        let lowLevel: Float = -50
        let highLevel: Float = -10
        var level = max(0.0, level - lowLevel)
        level = min(level, highLevel - lowLevel)
        return CGFloat(Float(level / (highLevel - lowLevel)))
    }
    func setTotalPlayTimeLabel(){
        if audioRecorder != nil{
            let audioLenSec = Int(audioPlayer!.duration)
            let min = audioLenSec / 60 < 10 ? "0" + String(audioLenSec / 60) : String(audioLenSec / 60)
            let sec = audioLenSec % 60 < 10 ? "0" + String(audioLenSec % 60) : String(audioLenSec % 60)
            self.createAudioView.totalLenLabel.text = min + ":" + sec
        }
        self.createAudioView.totalLenLabel.isHidden = false
    }
    func uploadDataToStorage(data: Data){
        let customData = CustomMetadata(length: createAudioView.totalLenLabel.text ?? "00:00")
        let storageMetadata = StorageMetadata()
        storageMetadata.customMetadata = customData.toDict()
        storageMetadata.contentType = "audio/mpeg"
        let audioInfo = AudioInfo(id: UUID().uuidString, data: data, metadata: storageMetadata)
        networkService.uploadAudio(audio: audioInfo) { error in
            if error != nil {
                print("firebase err: \(String(describing: error))")
                self.navigationController?.popViewController(animated: true) // 수정 필요
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func initAudioPlayer() {
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: audioRecorder!.url)
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
}

extension CreateAudioViewController{
    @objc private func tapCancel() {
        self.navigationController?.popViewController(animated: true)
    }
    @objc private func tapRecordingButton() {
        if createAudioView.recordingButton.isSelected{
            timer?.invalidate()
            audioRecorder?.stop()
            self.bottonsToggle(true)
            self.initAudioPlayer()
            self.setTotalPlayTimeLabel()
            self.scrollWavedProgressView(translation: 0.0, point: self.firstPoint)
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }else{
            self.arr = []
            createAudioView.wavedProgressView.layoutIfNeeded() // view reload 안됨
            createAudioView.wavedProgressView.xOffset = self.view.center.x / 3 - 1
            self.bottonsToggle(false)
            self.startRecording()
        }
    }
    @objc
    private func playButtonClicked() {
        if isPlaying == true{
            createAudioView.buttons.playButton.isSelected = false
            createAudioView.recordingButton.isEnabled = true
            timer?.invalidate()
            audioPlayer?.pause()
        }else{
            createAudioView.buttons.playButton.isSelected = true
            createAudioView.recordingButton.isEnabled = false
            audioPlayer?.delegate = self
            audioPlayer?.play()
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                if self.arr.count > self.index{
                    self.index += 1
                    self.createAudioView.wavedProgressView.scrollLayerScroll()
                }else{
                    timer.invalidate()
                    self.index = 0
                    self.isPlaying.toggle()
                    self.createAudioView.buttons.playButton.isSelected = false
                    self.createAudioView.recordingButton.isEnabled = true
                    self.scrollWavedProgressView(translation: 0.0, point: self.firstPoint)
                }
            }
        }
        isPlaying.toggle()
    }
    @objc
    func backButtonclicked() {
        if Double(audioPlayer!.currentTime) < 5 {
            self.audioPlayer?.currentTime = TimeInterval(0.0)
            self.index = 0
            self.scrollWavedProgressView(translation: 0.0, point: self.firstPoint)
        } else {
            self.audioPlayer?.currentTime = TimeInterval(audioPlayer!.currentTime - 5)
            self.index -= 50
            let newPoint = CGPoint(x: self.createAudioView.wavedProgressView.translation, y: 0.0)
            self.scrollWavedProgressView(translation: self.createAudioView.wavedProgressView.translation - 150, point: newPoint)
        }
    }
    @objc
    func forwardButtonClicked() {
        if Double(audioPlayer!.currentTime + 5) >= Double(audioPlayer!.duration) {
            self.audioPlayer?.currentTime = TimeInterval(audioPlayer!.duration)
            timer?.invalidate()
            self.index = 0
            self.isPlaying.toggle()
            self.createAudioView.buttons.playButton.isSelected = false
            self.createAudioView.recordingButton.isEnabled = true
            self.scrollWavedProgressView(translation: 0.0, point: self.firstPoint)
        } else {
            self.audioPlayer?.currentTime = TimeInterval(audioPlayer!.currentTime + 5)
            self.index += 50
            let newPoint = CGPoint(x: self.createAudioView.wavedProgressView.translation, y: 0.0)
            self.scrollWavedProgressView(translation: self.createAudioView.wavedProgressView.translation + 150, point: newPoint)
        }
    }
    @objc
    func tapDoneButton() {
        guard let audioRecorder = audioRecorder else {
            Alert.present(title: nil,
                          message: "녹음을 진행하지 않았습니다.",
                          actions: .ok(nil),
                          from: self)
            self.navigationController?.popViewController(animated: true)
            return
        }
        do {
            let data = try Data(contentsOf: audioRecorder.url)
            uploadDataToStorage(data: data)
            audioPlayer?.stop()
        } catch {
            print("error: \(error.localizedDescription)")
            audioPlayer?.stop()
            self.navigationController?.popViewController(animated: true) // 수정 필요
        }
    }
}


//        self.vm.averagePowerList.bind { list in
//            self.createAudioView.wavedProgressView.volumes = self.normalizeSoundLevel(level: db)
//            self.createAudioView.wavedProgressView.setNeedsDisplay()
//        }


//        AVFAudio.AVAudioEngine.audioUnit.AVAudioUnit.AVAudioUnitEQFilterParameters.frequency
//        let a = AVAudioEngine()
//        let eq = AVAudioUnitEQ(numberOfBands: 1)
//        let filterParams = eq.bands[0] as AVAudioUnitEQFilterParameters
//        filterParams.filterType = .lowPass
//        filterParams.frequency = 100.0
//        filterParams.bypass = false
//        a.attach(eq)


