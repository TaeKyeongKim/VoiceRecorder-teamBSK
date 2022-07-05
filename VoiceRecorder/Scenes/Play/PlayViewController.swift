//
//  PlayViewController.swift
//  VoiceRecorder
//
//  Created by Bran on 2022/06/29.
//

import AVFoundation
import UIKit

class PlayViewController: UIViewController {

  let playView = PlayView()
  var url: URL?
  var audio: Audio?

  override func viewDidLoad() {
    super.viewDidLoad()
    LoadingIndicator.showLoading()
    setupView()
    setupConstraints()
    setupAudio()
    bind()
    setupWaveform()
    setupAction()
    LoadingIndicator.hideLoading()
  }

  func setupView() {
    view.backgroundColor = .white
    playView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(playView)
  }

  func setupConstraints() {
    NSLayoutConstraint.activate([
      playView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      playView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      playView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      playView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
  }

  // MARK: - Test를 위해서 네트워크 통신 결과 URL 값을 바로 넣어주는 상태
  func setupAudio() {
    guard let url = url else { return }
    RecordFileManager.shared.saveRecordFile(recordName: "test", file: url)
    guard let file = RecordFileManager.shared.loadRecordFile("test") else { return }
    audio = Audio(file)
  }

  func setupWaveform() {
    guard let file = RecordFileManager.shared.loadRecordFile("test") else { return }
    playView.waveformView.generateWaveImage(from: file)
  }

  func bind() {
    audio?.playerProgress.bind({ value in
      self.playView.recorderSlider.value = Float(value)
    })

    audio?.playerTime.bind({ time in
      self.playView.totalTimeLabel.text = time.remainingText
      self.playView.spendTimeLabel.text = time.elapsedText
    })

    audio?.isPlaying.bind({ isplay in
      if isplay == false {
        self.playView.playButton.playButton.setImage(
          UIImage(systemName: "play.circle.fill"),
          for: .normal
        )
      } else {
        self.playView.playButton.playButton.setImage(
          UIImage(systemName: "pause.circle.fill"),
          for: .normal
        )
      }
    })
  }

  func setupAction() {
    playView.playButton.backButton.addTarget(
      self,
      action: #selector(backButtonclicked),
      for: .touchUpInside
    )
    playView.playButton.playButton.addTarget(
      self,
      action: #selector(playButtonClicked),
      for: .touchUpInside
    )
    playView.playButton.forwordButton.addTarget(
      self,
      action: #selector(forwardButtonClicked),
      for: .touchUpInside
    )
    playView.segmentControl.addTarget(
      self,
      action: #selector(segconChanged(segcon:)),
      for: .valueChanged
    )
    playView.recorderSlider.addTarget(
      self,
      action: #selector(sliderValueChanged(_:)),
      for: .valueChanged
    )
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(systemName: "chevron.backward"),
      style: .plain,
      target: self,
      action: #selector(navigationBackButtonClicked)
    )
  }

  @objc
  func navigationBackButtonClicked() {
    audio?.stop()
    RecordFileManager.shared.deleteRecordFile("test")
    self.navigationController?.popViewController(animated: true)
  }

  @objc
  func playButtonClicked() {
    print(#function)
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
  func segconChanged(segcon: UISegmentedControl) {
    guard audio != nil else { return }
    audio?.changePitch(segcon.selectedSegmentIndex)
  }

  @objc
  func sliderValueChanged(_ sender: UISlider) {
    audio?.seek(to: sender.value)
  }

}
