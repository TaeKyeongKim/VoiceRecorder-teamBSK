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
    let createAudioViewModel = CreateAudioViewModel()
    private var networkService: NetworkServiceable = Firebase()
    
    var audioPlayer: AVAudioPlayer?
    var timer: Timer?
    
    var averagePowerList: [CGFloat] = []
    var index: Int = 0
    var isPlaying = false
    let firstPoint = CGPoint(x: 0.0, y: 0.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationItems()
        setConstraint()
        setButtonsTarget()
        createAudioViewModel.setAudioRecorder()
        createAudioViewModel.setData()
        bind()
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
    func bottonsToggleWhenRecording(_ bool: Bool){
        self.createAudioView.recordingButton.isSelected = !bool
        self.createAudioView.buttons.playButton.isEnabled = bool
        self.createAudioView.currTimeLabel.isHidden = bool
        self.createAudioView.totalLenLabel.isHidden = !bool
        self.navigationItem.rightBarButtonItem?.isEnabled = bool
    }
    func backForwardButtonToggle(_ bool: Bool){
        self.createAudioView.buttons.backButton.isEnabled = bool
        self.createAudioView.buttons.forwordButton.isEnabled = bool
    }
    func startRecording() {
        createAudioViewModel.audioRecorder?.audioRecorder.delegate = self
        createAudioViewModel.audioRecorder?.audioRecorder.isMeteringEnabled = true
        createAudioViewModel.audioRecorder?.audioRecorder.record()
        self.setWavedProgress()
    }
    func scrollWavedProgressView(translation: CGFloat, point: CGPoint){
        self.createAudioView.wavedProgressView.translation = translation
        self.createAudioView.wavedProgressView.scrollLayer.scroll(point)
    }
    func setWavedProgress(){
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if let audioRecorder = self.createAudioViewModel.audioRecorder?.audioRecorder{
                audioRecorder.updateMeters()
                let db = audioRecorder.averagePower(forChannel: 0)
                self.averagePowerList.append(CGFloat(db))
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
        if createAudioViewModel.audioRecorder?.audioRecorder != nil{
            let audioLenSec = Int(audioPlayer!.duration)
            let min = audioLenSec / 60 < 10 ? "0" + String(audioLenSec / 60) : String(audioLenSec / 60)
            let sec = audioLenSec % 60 < 10 ? "0" + String(audioLenSec % 60) : String(audioLenSec % 60)
            self.createAudioView.totalLenLabel.text = min + ":" + sec
        }
    }
    
    func initAudioPlayer() {
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: (createAudioViewModel.audioRecorder?.audioRecorder.url)!)
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
      if createAudioView.recordingButton.isSelected {
            timer?.invalidate()
            createAudioViewModel.audioRecorder?.audioRecorder.stop()
            self.initAudioPlayer()
            self.setTotalPlayTimeLabel()
            self.bottonsToggleWhenRecording(true)
            self.scrollWavedProgressView(translation: 0.0, point: self.firstPoint)
        }else{
          if !averagePowerList.isEmpty {
            createAudioView.wavedProgressView.removeLayer()
            self.scrollWavedProgressView(translation: 0.0, point: self.firstPoint)
          }
          self.averagePowerList = []
          createAudioView.wavedProgressView.xOffset = self.view.center.x / 3 - 1
          self.bottonsToggleWhenRecording(false)
          self.startRecording()
        }
    }
    @objc
    private func playButtonClicked() {
        if isPlaying == true{
            createAudioView.recordingButton.isEnabled = true
            createAudioView.buttons.playButton.isSelected = false
            backForwardButtonToggle(false)
            timer?.invalidate()
            audioPlayer?.pause()
        }else{
            backForwardButtonToggle(true)
            createAudioView.recordingButton.isEnabled = false
            createAudioView.buttons.playButton.isSelected = true
            audioPlayer?.delegate = self
            audioPlayer?.play()
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                if self.averagePowerList.count > self.index{
                    self.index += 1
                    self.createAudioView.wavedProgressView.scrollLayerScroll()
                }else{
                    timer.invalidate()
                    self.index = 0
                    self.isPlaying.toggle()
                    self.backForwardButtonToggle(false)
                    self.createAudioView.recordingButton.isEnabled = true
                    self.createAudioView.buttons.playButton.isSelected = false
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
            timer?.invalidate()
            self.audioPlayer?.currentTime = TimeInterval(audioPlayer!.duration)
            self.index = 0
            self.isPlaying.toggle()
            self.createAudioView.recordingButton.isEnabled = true
            createAudioView.buttons.playButton.isSelected = false
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
        audioPlayer?.stop()
        guard let audioRecorder = createAudioViewModel.audioRecorder?.audioRecorder else { return }
        do {
            let data = try Data(contentsOf: audioRecorder.url)
            let lengthOfAudio = createAudioView.totalLenLabel.text ?? "00:00"
            createAudioViewModel.uploadDataToStorage(lengthOfAudio: lengthOfAudio, data: data) { _ in
                self.navigationController?.popViewController(animated: true)
            }
        } catch {
            print("error: \(error.localizedDescription)")
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension CreateAudioViewController{
    func bind(){
        createAudioViewModel.currTime.bind { time in
            self.createAudioView.currTimeLabel.text = time.currTimeText
        }
    }
}
