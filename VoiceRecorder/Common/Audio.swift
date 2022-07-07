//
//  Audio.swift
//  VoiceRecorder
//
//  Created by Bran on 2022/06/29.
//

import AVFoundation
import Foundation

// MARK: - 필요없는 프로퍼티, 메서드 정리 필요

enum TimeConstant {
  static let secsPerMin = 60
  static let secsPerHour = TimeConstant.secsPerMin * 60
}

struct PlayerTime {
  let elapsedText: String
  let remainingText: String

  static let zero: PlayerTime = .init(elapsedTime: 0, remainingTime: 0)

  init(elapsedTime: Double, remainingTime: Double) {
    elapsedText = PlayerTime.formatted(time: elapsedTime)
    remainingText = PlayerTime.formatted(time: remainingTime)
  }

  private static func formatted(time: Double) -> String {
    var seconds = Int(ceil(time))
    var hours = 0
    var mins = 0

    if seconds > TimeConstant.secsPerHour {
      hours = seconds / TimeConstant.secsPerHour
      seconds -= hours * TimeConstant.secsPerHour
    }

    if seconds > TimeConstant.secsPerMin {
      mins = seconds / TimeConstant.secsPerMin
      seconds -= mins * TimeConstant.secsPerMin
    }

    var formattedString = ""
    if hours > 0 {
      formattedString = "\(String(format: "%02d", hours)):"
    }
    formattedString += "\(String(format: "%02d", mins)):\(String(format: "%02d", seconds))"
    return formattedString
  }
}

class Audio {
  let audioPlayer = AVAudioPlayerNode()
  let engine = AVAudioEngine()
  let pitchControl = AVAudioUnitTimePitch()

  var isPlaying: Observable<Bool> = Observable(false)
  var isPlayerReady = false
  var needsFileScheduled = true

  var audioFile: AVAudioFile?
  var audioSampleRate: Double = 0
  var audioLengthSeconds: Double = 0

  var playerProgress: Observable<Double> = Observable(0.0)
  var playerTime: Observable<PlayerTime> = Observable(.zero)

  var displayLink: CADisplayLink?
  var seekFrame: AVAudioFramePosition = 0
  var currentPosition: AVAudioFramePosition = 0
  var audioLengthSamples: AVAudioFramePosition = 0

  var currentFrame: AVAudioFramePosition {
    guard
      let lastRenderTime = audioPlayer.lastRenderTime,
      let playerTime = audioPlayer.playerTime(forNodeTime: lastRenderTime)
    else {
      return 0
    }
    return playerTime.sampleTime
  }

  init(_ url: URL) {
    setupAudio(url)
    setupDisplayLink()
  }

  init(_ file: AVAudioFile) {
    setupAudio(file)
    setupDisplayLink()
  }

  private func setupAudio(_ url: URL) {
    do {
      let file = try AVAudioFile(forReading: url)
      let format = file.processingFormat

      audioLengthSamples = file.length
      audioSampleRate = format.sampleRate
      audioLengthSeconds = Double(audioLengthSamples) / audioSampleRate

      audioFile = file

      configureEngine(with: format)
    } catch {
      print("Error reading the audio file: \(error.localizedDescription)")
    }
  }

  private func setupAudio(_ file: AVAudioFile) {
    let format = file.processingFormat

    audioLengthSamples = file.length
    audioSampleRate = format.sampleRate
    audioLengthSeconds = Double(audioLengthSamples) / audioSampleRate

    print(format.sampleRate)

    audioFile = file

    configureEngine(with: format)
  }

  private func configureEngine(with format: AVAudioFormat) {
    engine.attach(audioPlayer)
    engine.attach(pitchControl)

    engine.connect(audioPlayer, to: pitchControl, format: nil)
    engine.connect(pitchControl, to: engine.mainMixerNode, format: nil)
    engine.prepare()

    do {
      try engine.start()
      scheduleAudioFile()
      isPlayerReady = true
    } catch {
      print("Error starting the player: \(error.localizedDescription)")
    }
  }

  private func scheduleAudioFile() {
    guard
      let file = audioFile,
      needsFileScheduled
    else {
      return
    }

    needsFileScheduled = false
    seekFrame = 0

    audioPlayer.scheduleFile(file, at: nil) {
      self.needsFileScheduled = true
    }
  }

  func stop() {
    displayLink?.isPaused = true
    audioPlayer.pause()
  }

  func playOrPause() {
    isPlaying.value.toggle()

    if audioPlayer.isPlaying {
      displayLink?.isPaused = true
      audioPlayer.pause()
    } else {
      displayLink?.isPaused = false

      if needsFileScheduled {
        scheduleAudioFile()
      }
      audioPlayer.play()
    }
  }

  func changePitch(_ index: Int) {
    switch index {
    case 0:
      pitchControl.pitch = 0
    case 1:
      pitchControl.pitch = 100
    case 2:
      pitchControl.pitch = -100
    default: return
    }
  }

  func skip(forwards: Bool) {
    let timeToSeek: Double
    if forwards {
      timeToSeek = 5
    } else {
      timeToSeek = -5
    }
    seek(to: timeToSeek)
  }

  // MARK: - 5초 전,후를 위한 로직
  private func seek(to time: Double) {
    guard let audioFile = audioFile else {
      return
    }

    let offset = AVAudioFramePosition(time * audioSampleRate)
    seekFrame = currentPosition + offset
    // 재생파일 시작과 끝을 넘어가는 case 대비
    seekFrame = max(seekFrame, 0)
    seekFrame = min(seekFrame, audioLengthSamples)
    currentPosition = seekFrame

    let wasPlaying = audioPlayer.isPlaying
    audioPlayer.stop()

    if currentPosition < audioLengthSamples {
      updateDisplay()
      needsFileScheduled = false

      let frameCount = AVAudioFrameCount(audioLengthSamples - seekFrame)
      audioPlayer.scheduleSegment(
        audioFile,
        startingFrame: seekFrame,
        frameCount: frameCount,
        at: nil
      ) {
        self.needsFileScheduled = true
      }

      if wasPlaying {
        audioPlayer.play()
      }
    }
  }

  // MARK: - 슬라이더
  func seek(to value: Float) {
    guard let audioFile = audioFile else {
      return
    }
    let sliderValue = audioLengthSeconds * Double(value) // Double
    seekFrame = AVAudioFramePosition(sliderValue * audioSampleRate)
    currentPosition = seekFrame

    let wasPlaying = audioPlayer.isPlaying
    audioPlayer.stop()

    if currentPosition < audioLengthSamples {
      updateDisplay()
      needsFileScheduled = false

      let frameCount = AVAudioFrameCount(audioLengthSamples - seekFrame)
      audioPlayer.scheduleSegment(
        audioFile,
        startingFrame: seekFrame,
        frameCount: frameCount,
        at: nil
      ) {
        self.needsFileScheduled = true
      }

      if wasPlaying {
        audioPlayer.play()
      }
    }
  }


  private func setupDisplayLink() {
    displayLink = CADisplayLink(
      target: self,
      selector: #selector(updateDisplay)
    )
    displayLink?.add(to: .current, forMode: .default)
    displayLink?.isPaused = true
  }


  @objc
  private func updateDisplay() {
    currentPosition = currentFrame + seekFrame
    currentPosition = max(currentPosition, 0)
    currentPosition = min(currentPosition, audioLengthSamples)

    if currentPosition >= audioLengthSamples {
      audioPlayer.stop()

      seekFrame = 0
      currentPosition = 0

      isPlaying.value = false
      displayLink?.isPaused = true
    }

    playerProgress.value = Double(currentPosition) / Double(audioLengthSamples)

    let time = Double(currentPosition) / audioSampleRate
    playerTime.value = PlayerTime(
      elapsedTime: time,
      remainingTime: audioLengthSeconds - time
    )
  }
}
