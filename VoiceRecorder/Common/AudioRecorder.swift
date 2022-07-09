//
//  AudioRecorder.swift
//  VoiceRecorder
//
//  Created by dong eun shin on 2022/07/09.
//

import Foundation

import AVFoundation

struct AudioRecorderTime {
  let currTimeText: String
  static let zero: AudioRecorderTime = .init(currTime: 0)
    
  init(currTime: Int) {
    currTimeText = AudioRecorderTime.formatted(time: currTime)
  }

  private static func formatted(time: Int) -> String {
      let audioLenSec = time
      let min = audioLenSec / 60 < 10 ? "0" + String(audioLenSec / 60) : String(audioLenSec / 60)
      let sec = audioLenSec % 60 < 10 ? "0" + String(audioLenSec % 60) : String(audioLenSec % 60)
      let formattedString = min + ":" + sec
    return formattedString
  }
}


class AudioRecorder{
    var audioRecorder = AVAudioRecorder()
    var currTime: Observable<AudioRecorderTime> = Observable(.zero)
    var displayLink: CADisplayLink?

    init() {
        setupAudioRecorder()
    }
    private func setupAudioRecorder() {
        let fileURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("fileName.m4a")
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
            setupDisplayLink()
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
    func pause(){
        displayLink?.isPaused = false
    }
    private func setupDisplayLink() {
      displayLink = CADisplayLink(
        target: self,
        selector: #selector(updateCurrTime)
      )
      displayLink?.add(to: .current, forMode: .default)
      displayLink?.isPaused = false
    }
    @objc
    private func updateCurrTime() {
        let time = Int(audioRecorder.currentTime)
        currTime.value = AudioRecorderTime(currTime: time)
    }
}
