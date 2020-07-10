//
//  Thunderbug.swift
//  PestControl
//
//  Created by Brendon Smy on 2020-07-07.
//  Copyright © 2020 Ray Wenderlich. All rights reserved.
//

import Foundation

import SpriteKit

class Thunderbug: Bug {
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init() {
    super.init()
    name = "Thunderbug"
    color = .orange
    colorBlendFactor = 1
    physicsBody?.velocity = CGVector(dx: 10, dy: 10)
    physicsBody?.categoryBitMask = PhysicsCategory.Thunderbug
  }
}
