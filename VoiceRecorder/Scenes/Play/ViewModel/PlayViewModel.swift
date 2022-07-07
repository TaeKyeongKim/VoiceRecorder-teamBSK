//
//  PlayViewModel.swift
//  VoiceRecorder
//
//  Created by Bran on 2022/07/07.
//

import Foundation

class PlayViewModel {
  var url: URL?
  private var audio: Audio?
  var isPlaying: Observable<Bool> = Observable(false)
  var playerProgress: Observable<Double> = Observable(0.0)
  var playerTime: Observable<PlayerTime> = Observable(.zero)

  func setupAudio() {
    guard let url = url else { return }
    RecordFileManager.shared.saveRecordFile(recordName: "test", file: url)
    guard let file = RecordFileManager.shared.loadRecordFile("test") else { return }
    audio = Audio(file)
  }

  func setupData() {
    guard let audio = audio else { return }
    self.isPlaying = audio.isPlaying
    self.playerProgress = audio.playerProgress
    self.playerTime = audio.playerTime
  }

  func stop() {
    audio?.stop()
    RecordFileManager.shared.deleteRecordFile("test")
  }

  func playOrPause() {
    audio?.playOrPause()
  }

  func back() {
    audio?.skip(forwards: false)
  }

  func forward() {
    audio?.skip(forwards: true)
  }

  func changePitch(_ index: Int) {
    audio?.changePitch(index)
  }

  func sliderChanged(_ val: Float) {
    audio?.seek(to: val)
  }
  
}
