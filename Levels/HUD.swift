//
//  HUD.swift
//  PestControl
//
//  Created by Brendon Smy on 2020-06-26.
//  Copyright © 2020 Ray Wenderlich. All rights reserved.
//

import Foundation
import SpriteKit

enum HUDMessages {
  static let tapToStart = "Tap to Start"
  static let win = "You Win!"
  static let lose = "Out of Time!"
  static let nextLevel = "Tap for Next Level"
  static let playAgain = "Tap to Play Again"
  static let reload = "Continue Previous Game?"
  static let yes = "Yes"
  static let no = "No"
}

enum HUDSettings {
  static let font = "Noteworthy-Bold"
  static let fontSize: CGFloat = 50
  
}

class HUD: SKNode {
  
  var timerLabel: SKLabelNode?
  var bugCounter: SKLabelNode?
  var elementCounter: SKLabelNode?
  
  
  override init(){
    super.init()
    name = "HUD"
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    timerLabel = childNode(withName: "Timer") as? SKLabelNode
    bugCounter = childNode(withName: "BugCounter") as? SKLabelNode
  }
  
  func updateGameState(from: GameState, to: GameState){
    clearUI(gameState: from)
    updateUI(gameState: to)
    
  }
  
  private func updateUI(gameState: GameState){
    //add messages for the new state
    switch gameState {
    case .win:
      add(message: HUDMessages.win, position: .zero)
      add(message: HUDMessages.nextLevel, position: CGPoint(x: 0, y: -100))
      
    case .lose:
      add(message: HUDMessages.lose, position: .zero)
      add(message: HUDMessages.playAgain, position: CGPoint(x: 0, y: -100))
      
    case .start:
      add(message: HUDMessages.tapToStart, position: .zero)
      
      case .reload:
      add(message: HUDMessages.reload, position: .zero, fontSize: 40)
      add(message: HUDMessages.yes, position: CGPoint(x: -140, y: -100))
      add(message: HUDMessages.no, position: CGPoint(x: 130, y: -100))
      
    default:
      break
    }
  }
  
  private func clearUI(gameState: GameState){
    //Clear Messages
    
    switch gameState {
    case .win:
      remove(messages: HUDMessages.win)
      remove(messages: HUDMessages.nextLevel)
      
    case .lose:
      remove(messages: HUDMessages.lose)
      remove(messages: HUDMessages.playAgain)
      
    case .start:
      remove(messages: HUDMessages.tapToStart)
      
    case .reload:
      remove(messages: HUDMessages.reload)
      remove(messages: HUDMessages.yes)
      remove(messages: HUDMessages.no)
      
    default:
      break
    }
  }
  
  private func remove(messages: String){
    childNode(withName: messages)?.removeFromParent()
  }
  
  func add(message: String, position: CGPoint, fontSize: CGFloat = HUDSettings.fontSize) {
    let label: SKLabelNode
    label = SKLabelNode(fontNamed: HUDSettings.font)
    
    label.text = message
    label.name = message
    label.zPosition = 100
    addChild(label)
    label.fontSize = fontSize
    label.position = position
  }

  
  func updateTimer(time: Int){
    let minutes = (time/60) % 60
    let seconds = time % 60
    let timeText = String(format: "%02d:%02d", minutes, seconds)
    timerLabel?.text = timeText
  }
  
  func addTimer(time: Int){
    guard let scene = scene else {return}
    
    let position = CGPoint(x: 0, y: scene.frame.height / 2 - 10)
    add(message: "Timer", position: position, fontSize: 24)
    timerLabel = childNode(withName: "Timer") as? SKLabelNode
    timerLabel?.verticalAlignmentMode = .top
    timerLabel?.fontName = "Menlo"
    updateTimer(time: time)
  }
  
  func updateCounter(bug: Int){
    
    let bugCount = bug
    let bugText = String(format: "Bug Count:%02d", bugCount)
    
    bugCounter?.text = bugText
    
  }
  
  func addCounter(bug: Int){
    
    guard let scene = scene else {return}
    
    let position = CGPoint(x: 200, y: scene.frame.height / 2 - 10)
    add(message: "BugCounter", position: position, fontSize: 24)
    bugCounter = childNode(withName: "BugCounter") as? SKLabelNode
    bugCounter?.verticalAlignmentMode = .top
    bugCounter?.fontName = "Menlo"
    
    updateCounter(bug: bug)
    
  }
  
  func addElementCounter(element: SKTexture){
    guard let scene = scene else {return}
    
    let position = CGPoint(x: -200, y: scene.frame.height / 2)
    add(message: "Elements", position: position, fontSize: 24)
    elementCounter = childNode(withName: "ElementCounter") as? SKLabelNode
    elementCounter?.verticalAlignmentMode = .top
    elementCounter?.fontName = "Menlo"
    
  }
  
}
