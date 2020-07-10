//
//  Rockbug.swift
//  PestControl
//
//  Created by Brendon Smy on 2020-07-07.
//  Copyright © 2020 Ray Wenderlich. All rights reserved.
//

import Foundation

import SpriteKit

class Rockbug: Bug {
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init() {
    super.init()
    name = "Rockbug"
    color = .darkGray
    colorBlendFactor = 1
    physicsBody?.categoryBitMask = PhysicsCategory.Rockbug
  }
}
