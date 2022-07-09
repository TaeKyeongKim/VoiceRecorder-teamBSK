//
//  HomeTableViewCell.swift
//  VoiceRecorder
//
//  Created by Kai Kim on 2022/06/29.
//

import UIKit

final class HomeTableViewCell: UITableViewCell {
  
  static let id = "HomeTableViewCell"
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setConstraints()
  }
  
  private var title: UILabel = {
    let label = UILabel()
    label.font = .mediumRegular
    return label
  }()
  
  private var length: UILabel = {
    let label = UILabel()
    label.font = .mediumRegular
    return label
  }()
  
  
  lazy var stackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [title, length])
    stackView.axis = .horizontal
    stackView.distribution = .fillProportionally
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  private func setConstraints() {
    contentView.addSubview(stackView)
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
    ])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(model: AudioPresentation?) {
    guard let model = model, let date = model.createdDate else{return}
    title.text = MyDateFormatter.shared.dateToString(from: date)
    self.length.text = model.length ?? ""
  }
  
}
