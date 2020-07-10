//
//  Types.swift
//  PestControl
//
//  Created by Brendon Smy on 2020-06-24.
//  Copyright © 2020 Ray Wenderlich. All rights reserved.
//

import Foundation

enum Direction: Int{
  case forward = 0, backward, left, right
}

typealias TileCoordinates = (column: Int, row: Int)

struct PhysicsCategory {
  static let None: UInt32 = 0
  static let All: UInt32 = 0xFFFFFFFF
  static let Edge: UInt32 = 0b1
  static let Player: UInt32 = 0b10
  static let Bug: UInt32 = 0b100
  static let Firebug: UInt32 = 0b1000
  static let Breakable: UInt32 = 0b10000
  static let Washable: UInt32 = 0b100000
  static let Waterbug: UInt32 = 0b1000000
  static let Grassbug: UInt32 = 0b10000000
  static let Rockbug: UInt32 = 0b100000000
  static let Thunderbug: UInt32 = 0b1000000000
  static let Megabug: UInt32 = 0b10000000000
  static let Zappable: UInt32 = 0b100000000000
  static let Choppable: UInt32 = 0b1000000000000
}

enum GameState: Int {
  case initial = 0, start, play, win, lose, reload, pause
}
