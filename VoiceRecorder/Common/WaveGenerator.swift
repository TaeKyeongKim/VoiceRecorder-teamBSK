//
//  WaveGenerator.swift
//  VoiceRecorder
//
//  Created by Bran on 2022/07/04.
//

import AVFoundation
import UIKit

class WaveGenerator {
  static func readBuffer(_ audioFile: AVAudioFile) -> [Float] {
    let audioFormat = audioFile.processingFormat
    let audioFrameCount = UInt32(audioFile.length)
    guard
      let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)
    else {
      return []
    }
    do {
      try audioFile.read(into: buffer)
    } catch {
      print("Read Buffer Error")
    }

    let floatArray = Array(UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength)))

    return floatArray
  }

  static func generateWaveImage(
    _ samples: [Float],
    _ imageSize: CGSize,
    _ strokeColor: UIColor,
    _ backgroundColor: UIColor
  ) -> UIImage? {
    let drawingRect = CGRect(origin: .zero, size: imageSize)

    UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)

    let middleY = imageSize.height / 2

    guard
      let context: CGContext = UIGraphicsGetCurrentContext()
    else {
      return nil
    }

    context.setFillColor(backgroundColor.cgColor)
    context.setAlpha(1.0)
    context.fill(drawingRect)
    context.setLineWidth(0.25)

    let max: CGFloat = CGFloat(samples.max() ?? 0)
    let heightNormalizationFactor = imageSize.height / max / 2
    let widthNormalizationFactor = imageSize.width / CGFloat(samples.count)
    for index in 0 ..< samples.count {
      let pixel = CGFloat(samples[index]) * heightNormalizationFactor
      let x = CGFloat(index) * widthNormalizationFactor

      context.move(to: CGPoint(x: x, y: middleY - pixel))
      context.addLine(to: CGPoint(x: x, y: middleY + pixel))

      context.setStrokeColor(strokeColor.cgColor)
      context.strokePath()
    }
    guard let soundWaveImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }

    UIGraphicsEndImageContext()
    return soundWaveImage
  }
}

extension UIImageView {
  func generateWaveImage(from audioFile: AVAudioFile) {
    let samples = WaveGenerator.readBuffer(audioFile)
    DispatchQueue.main.async {
      let img = WaveGenerator.generateWaveImage(
        samples,
        CGSize(width: self.frame.width, height: self.frame.height),
        UIColor.blue,
        UIColor.white
      )
      self.image = img
    }
  }
}
