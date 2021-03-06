//
//  TextFieldGroupView.swift
//  Harvest
//
//  Created by Letanyan Arumugam on 2018/04/18.
//  Copyright © 2018 University of Pretoria. All rights reserved.
//

import UIKit

class TextFieldGroupView: UIView {

  override init(frame: CGRect) {
    super.init(frame: frame)
    clearsContextBeforeDrawing = true
    isOpaque = false
    backgroundColor = UIColor(white: 0, alpha: 0)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    clearsContextBeforeDrawing = true
    isOpaque = false
    backgroundColor = UIColor(white: 0, alpha: 0)
  }
  
  override func draw(_ rect: CGRect) {
    let leftInset: CGFloat = 32.0
    let back = UIColor(white: 1, alpha: 0.67)
    let border = UIColor(white: 0.67, alpha: 1)
    
    let path = UIBezierPath(rect: rect)
    back.setFill()
    border.setStroke()
    
    path.fill()
    let seps = Int((rect.height - 42) / 38)
    
    let line = UIBezierPath(rect: CGRect(x: leftInset,
                                         y: 42,
                                         width: rect.width - leftInset,
                                         height: 1.0))
    border.setFill()
    line.fill()
    for i in 1..<seps {
      let line = UIBezierPath(rect: CGRect(x: leftInset,
                                           y: 42 + CGFloat(i) * 38,
                                           width: rect.width - leftInset,
                                           height: 1.0))
      line.fill()
    }
    
    layer.cornerRadius = 5
    layer.masksToBounds = true
  }

}
