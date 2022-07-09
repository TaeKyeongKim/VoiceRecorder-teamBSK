//
//  PlayViewModel.swift
//  VoiceRecorder
//
//  Created by Bran on 2022/07/07.
//

import Foundation

class PlayViewModel {
  private var url: URL?
  private var audio: Audio?
  var isPlaying: Observable<Bool> = Observable(false)
  var playerProgress: Observable<Double> = Observable(0.0)
  var playerTime: Observable<PlayerTime> = Observable(.zero)

  func setupURL(_ url: URL) {
    self.url = url
  }

  func setupAudio() {
    guard let url = url else { return }
    RecordFileManager.shared.saveRecordFile(recordName: "test", file: url)
    guard let file = RecordFileManager.shared.loadRecordFile("test") else { return }
    audio = Audio(file)
  }

  func setupData() {
    guard let audio = audio else { return }
    audio.isPlaying.bind { val in
      self.isPlaying.value = val
    }
    audio.playerProgress.bind { val in
      self.playerProgress.value = val
    }
    audio.playerTime.bind { val in
      self.playerTime.value = val
    }
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
