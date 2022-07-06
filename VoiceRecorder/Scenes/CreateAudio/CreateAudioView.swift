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
        config()
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
    lazy var totalLenLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.isHidden = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var recordingButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("시작", for: .normal)
        button.setTitle("중지", for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("Done", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    func setButtons(){
        buttons.playButton.isEnabled = false
        buttons.backButton.isEnabled = false
        buttons.forwordButton.isEnabled = false
        buttons.translatesAutoresizingMaskIntoConstraints = false
    }
    func config(){
        self.addSubview(wavedProgressView)
        self.addSubview(recordingButton)
        self.addSubview(buttons)
        self.addSubview(doneButton)
        self.addSubview(totalLenLabel)
        NSLayoutConstraint.activate([
//            wavedProgressView.topAnchor.constraint(equalTo: self.topAnchor, constant: 150),
            wavedProgressView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            wavedProgressView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            wavedProgressView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            wavedProgressView.heightAnchor.constraint(equalToConstant: 250),

//            wavedProgressView.bottomAnchor.constraint(equalTo: totalLenLabel.topAnchor, constant: -25),
//            wavedProgressView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -400)
            
//            totalLenLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 100),
            totalLenLabel.bottomAnchor.constraint(equalTo: recordingButton.topAnchor, constant: -25),
            totalLenLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            totalLenLabel.heightAnchor.constraint(equalToConstant: 50),
            totalLenLabel.widthAnchor.constraint(equalToConstant: 200),
            
//            recordingButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 300),
            recordingButton.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -25),
            recordingButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            recordingButton.heightAnchor.constraint(equalToConstant: 50),
            recordingButton.widthAnchor.constraint(equalToConstant: 50),
            
//            doneButton.topAnchor.constraint(equalTo: recordingButton.bottomAnchor, constant: 100),
            doneButton.bottomAnchor.constraint(equalTo: buttons.topAnchor, constant: -25),
            doneButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            doneButton.heightAnchor.constraint(equalToConstant: 50),
            doneButton.widthAnchor.constraint(equalToConstant: 50),
            
            buttons.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -25),
            buttons.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            buttons.widthAnchor.constraint(equalToConstant: 200),
        ])
    }
}
