//
//  CreateAudioView.swift
//  VoiceRecorder
//
//  Created by dong eun shin on 2022/07/04.
//

import UIKit

class CreateAudioView: UIView {
    override init(frame: CGRect) {
      super.init(frame: frame)
        setButtons()
        setConstraint()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let buttons = PlayButtonView()
    var wavedProgressView: WavedProgressView = {
        var view = WavedProgressView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var line: UIView = {
        var view = UIView()
        view.backgroundColor = .systemBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var totalLenLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.isHidden = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var currTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var recordingButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemBlue, for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 35), forImageIn: .normal)
        button.setImage(UIImage(systemName: "record.circle"), for: .selected)
        button.setImage(UIImage(systemName: "record.circle.fill"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    func setButtons(){
        self.buttons.playButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .selected)
        self.buttons.playButton.isEnabled = false
        self.buttons.backButton.isEnabled = false
        self.buttons.forwordButton.isEnabled = false
        self.buttons.translatesAutoresizingMaskIntoConstraints = false
    }
    func setConstraint(){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(wavedProgressView)
        self.addSubview(recordingButton)
        self.addSubview(buttons)
        self.addSubview(totalLenLabel)
        self.addSubview(currTimeLabel)
        wavedProgressView.addSubview(line)
        NSLayoutConstraint.activate([
            wavedProgressView.topAnchor.constraint(equalTo: self.topAnchor, constant: 50),
            wavedProgressView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            wavedProgressView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            wavedProgressView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            wavedProgressView.heightAnchor.constraint(equalToConstant: 150),

            line.topAnchor.constraint(equalTo: wavedProgressView.topAnchor),
            line.bottomAnchor.constraint(equalTo: wavedProgressView.bottomAnchor),
            line.widthAnchor.constraint(equalToConstant: 3),
            line.centerXAnchor.constraint(equalTo: wavedProgressView.centerXAnchor),
            
            currTimeLabel.topAnchor.constraint(equalTo: wavedProgressView.bottomAnchor, constant: 30),
            currTimeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            currTimeLabel.heightAnchor.constraint(equalToConstant: 50),
            currTimeLabel.widthAnchor.constraint(equalToConstant: 200),

            totalLenLabel.topAnchor.constraint(equalTo: wavedProgressView.bottomAnchor, constant: 30),
            totalLenLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            totalLenLabel.heightAnchor.constraint(equalToConstant: 50),
            totalLenLabel.widthAnchor.constraint(equalToConstant: 200),
            
            recordingButton.topAnchor.constraint(equalTo: totalLenLabel.bottomAnchor, constant: 30),
            recordingButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            recordingButton.heightAnchor.constraint(equalToConstant: 50),
            recordingButton.widthAnchor.constraint(equalToConstant: 50),
            
            buttons.topAnchor.constraint(equalTo: recordingButton.bottomAnchor, constant: 30),
            buttons.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            buttons.widthAnchor.constraint(equalToConstant: 200),
        ])
    }
}
