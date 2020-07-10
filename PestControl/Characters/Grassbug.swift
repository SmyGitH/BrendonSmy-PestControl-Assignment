//
//  Grassbug.swift
//  PestControl
//
//  Created by Brendon Smy on 2020-07-07.
//  Copyright © 2020 Ray Wenderlich. All rights reserved.
//

import Foundation

import SpriteKit

class Grassbug: Bug {
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init() {
    super.init()
    name = "Grassbug"
    color = .green
    colorBlendFactor = 1
    physicsBody?.categoryBitMask = PhysicsCategory.Grassbug
  }
}
