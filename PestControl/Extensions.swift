//
//  Extensions.swift
//  PestControl
//
//  Created by Brendon Smy on 2020-06-24.
//  Copyright © 2020 Ray Wenderlich. All rights reserved.
//

import Foundation
import SpriteKit

extension SKTexture {
  convenience init(pixelImageNamed: String){
    self.init(imageNamed: pixelImageNamed)
    self.filteringMode = .nearest
  }
}
