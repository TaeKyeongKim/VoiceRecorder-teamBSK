//
//  File.swift
//  VoiceRecorder
//
//  Created by dong eun shin on 2022/07/05.
//

import UIKit

class WavedProgressView: UIView {
    
    var lineMargin:CGFloat = 2.0
    
    lazy var volumes:CGFloat = 0.0 {
        didSet{
            self.drawVerticalLines(volumes)
            if xOffset >= self.frame.width.magnitude * 0.25 {
                scrollLayerScroll()
            }
        }
    }
    
    
    lazy var xOffset: CGFloat = 0
    lazy var translation: CGFloat = 0//xOffset
    var lineWidth:CGFloat = 1.0

    lazy var scrollLayer : CAScrollLayer = {
        let scrollLayer = CAScrollLayer()
        scrollLayer.bounds = CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height)
        scrollLayer.position = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        scrollLayer.borderColor = UIColor.black.cgColor
        scrollLayer.borderWidth = 1.0
        scrollLayer.scrollMode = CAScrollLayerScrollMode.horizontally
        return scrollLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .brown
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func drawVerticalLines(_ value: CGFloat) {
        let linePath = CGMutablePath()
        let height = self.frame.height * value
        let y = (self.frame.height - height) / 2.0
        linePath.addRect(CGRect(x: lineMargin + (lineMargin + lineWidth) * CGFloat(xOffset), y: y, width: lineWidth, height: height))
        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath
        lineLayer.lineWidth = 0.5
        lineLayer.strokeColor = UIColor.white.cgColor
        xOffset += 1
        self.layer.addSublayer(scrollLayer)
        scrollLayer.addSublayer(lineLayer)
    }

    func scrollLayerScroll() {
        let newPoint = CGPoint(x: translation, y: 0.0)
        scrollLayer.scroll(newPoint)
        translation += 3
    }
}
