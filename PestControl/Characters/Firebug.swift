//
//  Firebug.swift
//  PestControl
//
//  Created by Brendon Smy on 2020-06-25.
//  Copyright © 2020 Ray Wenderlich. All rights reserved.
//

import SpriteKit

class Firebug: Bug {
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init() {
    super.init()
    name = "Firebug"
    color = .red
    colorBlendFactor = 0.8
    physicsBody?.categoryBitMask = PhysicsCategory.Firebug
  }
}

