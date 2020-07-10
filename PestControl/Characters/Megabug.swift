//
//  Windbug.swift
//  PestControl
//
//  Created by Brendon Smy on 2020-07-07.
//  Copyright © 2020 Ray Wenderlich. All rights reserved.
//

import Foundation

import SpriteKit

class Megabug: Bug {
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init() {
    super.init()
    name = "Megabug"
    color = .magenta
    colorBlendFactor = 1
    xScale = 10
    yScale = 10
    physicsBody?.categoryBitMask = PhysicsCategory.Megabug
  }
}
