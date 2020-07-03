//
//  Bug.swift
//  PestControl
//
//  Created by Brendon Smy on 2020-06-24.
//  Copyright © 2020 Ray Wenderlich. All rights reserved.
//

import SpriteKit

enum BugSetting {
  static let bugDistance: CGFloat = 16
}

class Bug: SKSpriteNode {
  
  
  
  var animations : [SKAction] = []
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    animations = aDecoder.decodeObject(forKey: "Bug.animations") as! [SKAction]
  }
  
  init(){
    
    let texture = SKTexture(pixelImageNamed: "bug_ft1")
    super.init(texture: texture, color: .white, size: texture.size())
    name = "Bug"
    zPosition = 50
    
    physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
    physicsBody?.restitution = 0.5
    physicsBody?.allowsRotation = false
    physicsBody?.categoryBitMask = PhysicsCategory.Bug
    
    createAnimations(character: "bug")
    
  }
  
  @objc func moveBug(){
    let randomX = CGFloat(Int.random(min: -1, max: 1))
    let randomY = CGFloat(Int.random(min: -1, max: 1))
    
    let vector = CGVector(dx: randomX * BugSetting.bugDistance, dy: randomY * BugSetting.bugDistance)
    
    let moveBy = SKAction.move(by: vector, duration: 1)
    let moveAgain = SKAction.perform(#selector(moveBug), onTarget: self)
    
    let direction = animationDirection(for: vector)
    
    if direction == .left{
      xScale = abs(xScale)
    }else if direction == .right{
      xScale = -abs(xScale)
    }
    
    run(animations[direction.rawValue], withKey: "animation")
    run(SKAction.sequence([moveBy, moveAgain]))
  }
  
  func die(){
    removeAllActions()
    texture = SKTexture(pixelImageNamed: "bug_lt1")
    
    yScale = -1
    
    physicsBody = nil
    
    run(SKAction.sequence([SKAction.fadeOut(withDuration: 3),
                             SKAction.removeFromParent()]))

  }
  
  override func encode(with aCoder: NSCoder) {
    aCoder.encode(animations, forKey: "Bug.animations")
    super.encode(with: aCoder)
  }
  
}

extension Bug: Animatable{}
