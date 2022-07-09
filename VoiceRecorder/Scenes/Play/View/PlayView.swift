//
//  PlayView.swift
//  VoiceRecorder
//
//  Created by Bran on 2022/06/29.
//

import UIKit
import MediaPlayer

class PlayView: UIView {
  let playButton = PlayButtonView()
  let volumeView = MPVolumeView() // MARK: - Volume 조절, Simulator 동작x
  let waveformView = UIImageView()
  let volumeLabel = UILabel()

  let segmentControl = UISegmentedControl(items: ["일반 목소리", "아기 목소리", "할아버지 목소리"])

  // TODO: - 모듈화 시킬지 생각해보기
  let recorderSlider = UISlider()
  let spendTimeLabel = UILabel()
  let totalTimeLabel = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    setupConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("PlayView Error")
  }

  func setupView() {
    [playButton, volumeView, volumeLabel, segmentControl, recorderSlider, spendTimeLabel, totalTimeLabel, waveformView].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      $0.backgroundColor = .white
      self.addSubview($0)
    }
//    volumeView.backgroundColor = .systemBlue // MARK: - Simulator size
    segmentControl.selectedSegmentIndex = 0
    setupLabel()
  }

  func setupConstraints() {
    NSLayoutConstraint.activate([
      recorderSlider.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -25), // MARK: -
      recorderSlider.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 18),
      recorderSlider.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -18),
    ])

    NSLayoutConstraint.activate([
      waveformView.bottomAnchor.constraint(equalTo: recorderSlider.topAnchor, constant: -25),
      waveformView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 18),
      waveformView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -18),
      waveformView.heightAnchor.constraint(equalToConstant: 100),
    ])

    NSLayoutConstraint.activate([
      spendTimeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 18),
      spendTimeLabel.topAnchor.constraint(equalTo: recorderSlider.bottomAnchor, constant: 18),
    ])

    NSLayoutConstraint.activate([
      totalTimeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -18),
      totalTimeLabel.topAnchor.constraint(equalTo: recorderSlider.bottomAnchor, constant: 18),
    ])

    NSLayoutConstraint.activate([
      playButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -25),
      playButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      playButton.widthAnchor.constraint(equalToConstant: 200),
    ])

    NSLayoutConstraint.activate([
      volumeView.bottomAnchor.constraint(equalTo: playButton.topAnchor, constant: -25),
      volumeView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 18),
      volumeView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -18),
      volumeView.heightAnchor.constraint(equalToConstant: 20),
    ])

    NSLayoutConstraint.activate([
      volumeLabel.bottomAnchor.constraint(equalTo: volumeView.topAnchor, constant: -18),
      volumeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 18),
    ])

    NSLayoutConstraint.activate([
      segmentControl.bottomAnchor.constraint(equalTo: volumeLabel.topAnchor, constant: -25),
      segmentControl.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 18),
      segmentControl.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -18),
    ])

  }

  private func setupLabel() {
    [volumeLabel, spendTimeLabel, totalTimeLabel].forEach {
      $0.textColor = .black
      $0.font = .systemFont(ofSize: 13, weight: .medium)
    }
    volumeLabel.text = "Volume"
    spendTimeLabel.text = "00:00"
    totalTimeLabel.text = "00:00"
  }
}
