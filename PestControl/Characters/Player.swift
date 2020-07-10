//
//  Player.swift
//  PestControl
//
//  Created by Brendon Smy on 2020-06-24.
//  Copyright © 2020 Ray Wenderlich. All rights reserved.
//

import SpriteKit

enum PlayerSettings {
  static let playerSpeed: CGFloat = 200
}

class Player: SKSpriteNode {
  
  var animations: [SKAction] = []

  
  var hasBugspray: Bool = false{
    didSet {
      blink(color: .white, on: hasBugspray)
    }
  }
  
  var hasFireElement: Bool = false {
    didSet {
      blink(color: .red, on: hasFireElement)
    }
  }
  
  var hasWaterElement: Bool = false {
    didSet {
      blink(color: .blue, on: hasWaterElement)
    }
  }
  
  var hasRockElement: Bool = false {
    didSet {
      blink(color: .darkGray, on: hasRockElement)
    }
  }
  
  var hasGrassElement: Bool = false {
    didSet {
      blink(color: .green, on: hasGrassElement)
    }
  }
  
  var hasThunderElement: Bool = false {
    didSet {
      blink(color: .orange, on: hasThunderElement)
    }
  }
  
  var hasEveryElement: Bool = false {
    didSet {
      megaForm(on: hasEveryElement)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    animations = aDecoder.decodeObject(forKey: "Player.animations") as! [SKAction]
    hasBugspray = aDecoder.decodeBool(forKey: "Player.hasBugspray")
    
    if hasBugspray {
      removeAction(forKey: "blink")
      blink(color: .green, on: hasBugspray)
    }
    
    if hasFireElement {
      removeAction(forKey: "blink")
      blink(color: .red, on: hasFireElement)
    }
    
    if hasWaterElement {
      removeAction(forKey: "blink")
      blink(color: .blue, on: hasWaterElement)
    }
    
    if hasThunderElement {
      removeAction(forKey: "blink")
      blink(color: .orange, on: hasThunderElement)
    }
    if hasRockElement {
      removeAction(forKey: "blink")
      blink(color: .darkGray, on: hasRockElement)
    }
    if hasGrassElement{
      removeAction(forKey: "blink")
      blink(color: .green, on: hasGrassElement)
    }
    if hasEveryElement{
      removeAction(forKey: "mega")
      megaForm(on: hasEveryElement)
    }
  }
  
  init(){
    let texture = SKTexture(pixelImageNamed: "player_ft1")
    super.init(texture: texture, color: .white, size: texture.size())
    name = "Player"
    zPosition = 50
    
    physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
    physicsBody?.restitution = 1.0
    physicsBody?.linearDamping = 0.5
    physicsBody?.friction = 0
    physicsBody?.allowsRotation = false
    physicsBody?.categoryBitMask = PhysicsCategory.Player
    physicsBody?.contactTestBitMask = PhysicsCategory.All
    
    createAnimations(character: "player")
    
  }
  
  func move(target: CGPoint){
    guard let physicsBody = physicsBody else{
      return
    }
    
    let newVelocity = (target - position).normalized() * PlayerSettings.playerSpeed
    physicsBody.velocity = CGVector(point: newVelocity)
    
    checkDirection()
    
    print("*\(animationDirection(for: physicsBody.velocity))")
  }
  
  func checkDirection(){
    guard let physicsBody = physicsBody else {
      return
    }
    
    let direction = animationDirection(for: physicsBody.velocity)
    
    if direction == .left{
      xScale = abs(xScale)
    }
    
    if direction == .right{
      xScale = -abs(xScale)
    }
    
    run(animations[direction.rawValue], withKey: "animation")
  }
  
  func blink(color: SKColor, on: Bool){
    let blinkOff = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.2)
    
    if on {
      let blinkOn = SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: 0.2)
      let blink = SKAction.repeatForever(SKAction.sequence([blinkOn, blinkOff]))
      
      
      run(blink, withKey: "blink")
    }else{
      
      removeAction(forKey: "blink")
      run(blinkOff)
    }
  }
  
  func megaForm(on: Bool){
    let megaOff = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.2)
       
       if on {
         let redOn = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.2)
         let blueOn = SKAction.colorize(with: .blue, colorBlendFactor: 1.0, duration: 0.2)
         let greenOn = SKAction.colorize(with: .green, colorBlendFactor: 1.0, duration: 0.2)
         let darkGrayOn = SKAction.colorize(with: .darkGray, colorBlendFactor: 1.0, duration: 0.2)
         let orangeOn = SKAction.colorize(with: .orange, colorBlendFactor: 1.0, duration: 0.2)
         let mega = SKAction.repeatForever(SKAction.sequence([redOn,blueOn,greenOn,darkGrayOn,orangeOn]))
         
         xScale = xScale < 0 ? -1.5: 1.5
         yScale = 1.5
         run(mega, withKey: "mega")
       }else{
         xScale = xScale < 0 ? -1.0 : 1.0
         yScale = 1.0
         removeAction(forKey: "mega")
         run(megaOff)
       }
  }
  
  
  
  override func encode(with aCoder: NSCoder) {
    aCoder.encode(hasBugspray, forKey: "Player.hasBugspray")
    aCoder.encode(animations, forKey: "Player.animations")
    super.encode(with: aCoder)
  }
  
}

extension Player : Animatable{}
