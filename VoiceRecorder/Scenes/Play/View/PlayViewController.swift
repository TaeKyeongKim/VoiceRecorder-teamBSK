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
  let playViewModel = PlayViewModel()

  init(_ url: URL) {
    super.init(nibName: nil, bundle: nil)
    playViewModel.setupURL(url)
  }

  required init?(coder: NSCoder) {
    fatalError("Play ViewController Error")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    LoadingIndicator.showLoading()
    setupView()
    setupConstraints()
    playViewModel.setupAudio()
    playViewModel.setupData()
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

  func setupWaveform() {
    guard let file = RecordFileManager.shared.loadRecordFile("test") else { return }
    playView.waveformView.generateWaveImage(from: file)
  }

  func bind() {
    playViewModel.playerProgress.bind { value in
      self.playView.recorderSlider.value = Float(value)
    }
    playViewModel.playerTime.bind { time in
      self.playView.totalTimeLabel.text = time.remainingText
      self.playView.spendTimeLabel.text = time.elapsedText
    }
    playViewModel.isPlaying.bind { isPlay in
      if isPlay == false {
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
    }
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
    playViewModel.stop()
    self.navigationController?.popViewController(animated: true)
  }

  @objc
  func playButtonClicked() {
    playViewModel.playOrPause()
  }

  @objc
  func backButtonclicked() {
    playViewModel.back()
  }

  @objc
  func forwardButtonClicked() {
    playViewModel.forward()
  }

  @objc
  func segconChanged(segcon: UISegmentedControl) {
    playViewModel.changePitch(segcon.selectedSegmentIndex)
  }

  @objc
  func sliderValueChanged(_ sender: UISlider) {
    playViewModel.sliderChanged(sender.value)
  }
}
