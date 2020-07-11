/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SpriteKit

class GameScene: SKScene {
  var background: SKTileMapNode!
  var player = Player()
  
  var bugsNode = SKNode()
  
  var obstaclesTileMap : SKTileMapNode?
  
  var fireBugCount: Int = 0
  var normalBugCount : Int = 0
  var waterBugCount : Int = 0
  var grassBugCount: Int = 0
  var rockBugCount: Int = 0
  var thunderBugCount: Int = 0
  var megaBugCount: Int = 0
  
  
  
  
  var bugsprayTileMap: SKTileMapNode?
  var fireElementTileMap: SKTileMapNode?
  
  var hud = HUD()
  var timeLimit: Int = 10
  var elapsedTime: Int = 0
  var startTime: Int?
  var megaTime: Double = 0
  
  var currentLevel: Int = 1
  
  var gameState: GameState = .initial {
    didSet {
      hud.updateGameState(from: oldValue, to: gameState)
    }
  }
  
 // var bug = Bug()
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    background = childNode(withName: "background") as! SKTileMapNode
    obstaclesTileMap = childNode(withName: "Obstacles") as? SKTileMapNode
    
    if let timeLimit = userData?.object(forKey: "timeLimit") as? Int {
      self.timeLimit = timeLimit
    }
    
    let savedGameState = aDecoder.decodeInteger(forKey: "Scene.gameState")
    if let gameState = GameState(rawValue: savedGameState), gameState == .pause {
    self.gameState = gameState
      fireBugCount = aDecoder.decodeInteger(forKey: "Scene.firebugCount")
      elapsedTime = aDecoder.decodeInteger(forKey: "Scene.elapsedTime")
      currentLevel = aDecoder.decodeInteger(forKey: "Scene.currentLevel")
      
      player = childNode(withName: "Player") as! Player
      hud = camera!.childNode(withName: "HUD") as! HUD
      bugsNode = childNode(withName: "Bugs")!
      bugsprayTileMap = childNode(withName: "Bugspray") as? SKTileMapNode
      fireElementTileMap = childNode(withName: "Flame") as? SKTileMapNode
    }
    
    addObservers()
  }
  
  
  
  func transitionToScene(level: Int){
    guard let  newScene = SKScene(fileNamed: "Level\(level)") as? GameScene else {
      fatalError("Level: \(level) not found")
    }
    
    newScene.currentLevel = level
    view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.5))
  }
  
  func updateHUD(currentTime: TimeInterval){
    if let startTime = startTime{
      elapsedTime = Int(currentTime) - startTime
    }else{
      startTime = Int(currentTime) - elapsedTime
    }
    hud.updateTimer(time: timeLimit - elapsedTime)
  
    hud.updateCounter(bug: fireBugCount + normalBugCount + waterBugCount + grassBugCount + rockBugCount + thunderBugCount + megaBugCount)
    
    if player.hasFireElement{
       hud.addElementCounter(element: SKTexture(pixelImageNamed: "flame"))
    }
    
  }
  
  func setupHud(){
    camera?.addChild(hud)
    hud.addTimer(time: timeLimit)
    hud.addCounter(bug: fireBugCount + normalBugCount + waterBugCount + grassBugCount + rockBugCount + thunderBugCount + megaBugCount)
    
  }
  
  func checkEndGame(){
    if bugsNode.children.count == 0 {
      player.physicsBody?.linearDamping = 1
      gameState = .win
    }else if timeLimit - elapsedTime <= 0 {
      player.physicsBody?.linearDamping = 1
      gameState = .lose
    }
  }
  
  override func didMove(to view: SKView){
    //let totalBugCount = fireBugCount + waterBugCount + rockBugCount + thunderBugCount + grassBugCount + windBugCount
    if gameState == .initial{
      addChild(player)
      setupWorldPhysics()
      createBugs()
      setupObstaclePhysics()
      setupWashableTilePhysics()
      setupZapTilePhysics()
      setupChoppableTilePhysics()
      
      
      if normalBugCount > 0 || megaBugCount > 0 {
        createBugspray(quantity: 30)
      }
      
      if fireBugCount > 0 || megaBugCount > 0 {
        createFireElement(quantity: 100)
      }
    
      setupHud()
      gameState = .start
    }
    setupCamera()
    
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else{
      return
    }
    
    switch gameState {
    case .start:
      gameState = .play
      isPaused = false
      startTime = nil
      elapsedTime = 0
      
    case .play:
      player.move(target: touch.location(in: self))
      
    case .win:
      transitionToScene(level: currentLevel + 1)
      
    case .lose:
      transitionToScene(level: 1)
      
    case .reload:
      if let touchedNode = atPoint(touch.location(in: self)) as? SKLabelNode{
        if touchedNode.name == HUDMessages.yes {
          isPaused = false
          startTime = nil
          gameState = .play
        }else if touchedNode.name == HUDMessages.no{
          transitionToScene(level: 1)
        }
      }
      
      
    default:
      break
    }
    
    
  }
  
  func setupCamera(){
    guard let camera = camera, let view = view else{return}
    let zeroDistance = SKRange(constantValue: 0)
    let playerConstraint = SKConstraint.distance(zeroDistance, to: player)
    
    let xInset = min(view.bounds.width/2*camera.xScale, background.frame.width/2)
    let yInset = min(view.bounds.height/2*camera.yScale, background.frame.height/2)
    
    let constraintRect = background.frame.insetBy(dx: xInset, dy: yInset)
    
    let xRange = SKRange(lowerLimit: constraintRect.minX, upperLimit: constraintRect.maxX)
    
    let yRange = SKRange(lowerLimit: constraintRect.minY, upperLimit: constraintRect.maxY)
    
    let edgeConstraint = SKConstraint.positionX(xRange, y: yRange)
    
    edgeConstraint.referenceNode = background
    
    camera.constraints = [playerConstraint, edgeConstraint]
  }
  
  func setupWorldPhysics(){
    background.physicsBody = SKPhysicsBody(edgeLoopFrom: background.frame)
    background.physicsBody?.categoryBitMask = PhysicsCategory.Edge
    physicsWorld.contactDelegate = self
  }
  
  func tile(in tileMap: SKTileMapNode, at coordinates: TileCoordinates) -> SKTileDefinition? {
    return tileMap.tileDefinition(atColumn: coordinates.column, row: coordinates.row)
  }
  
  func createBugs(){
    guard let bugsMap = childNode(withName: "bugs") as? SKTileMapNode else {return}
    
    for row in 0..<bugsMap.numberOfRows {
      for column in 0..<bugsMap.numberOfColumns{
        guard let tile = tile(in: bugsMap, at: (column, row))
          else {continue}
        
        let bug: Bug
        
        if tile.userData?.object(forKey: "firebug") != nil {
          bug = Firebug()
          fireBugCount += 1
        }else if tile.userData?.object(forKey: "waterbug") != nil {
          bug = Waterbug()
          waterBugCount += 1
        }else if tile.userData?.object(forKey: "grassbug") != nil {
          bug = Grassbug()
          grassBugCount += 1
        }else if tile.userData?.object(forKey: "rockbug") != nil {
          bug = Rockbug()
          rockBugCount += 1
        }else if tile.userData?.object(forKey: "thunderbug") != nil {
          bug = Thunderbug()
          thunderBugCount += 1
        }else if tile.userData?.object(forKey: "megabug") != nil {
          bug = Megabug()
          megaBugCount += 1
        }else{
          bug = Bug()
          normalBugCount += 1
        }
        
        bug.position = bugsMap.centerOfTile(atColumn: column, row: row)
        bugsNode.addChild(bug)
        bug.moveBug()
      }
    }
    bugsNode.name = "Bugs"
    addChild(bugsNode)
    bugsMap.removeFromParent()
  }
  
func setupObstaclePhysics() {
      guard let obstaclesTileMap = obstaclesTileMap else { return }
      // 1
      for row in 0..<obstaclesTileMap.numberOfRows {
        for column in 0..<obstaclesTileMap.numberOfColumns {
          // 2
          guard let tile = tile(in: obstaclesTileMap,
                                at: (column, row))
            else { continue }
          guard tile.userData?.object(forKey: "obstacle") != nil
                  else { continue }
                // 3
                let node = SKNode()
                node.physicsBody = SKPhysicsBody(rectangleOf: tile.size)
                node.physicsBody?.isDynamic = false
                node.physicsBody?.friction = 0
                node.physicsBody?.categoryBitMask =
                  PhysicsCategory.Breakable

                node.position = obstaclesTileMap.centerOfTile(
                  atColumn: column, row: row)
                obstaclesTileMap.addChild(node)
            }
         }
      }
  func setupZapTilePhysics(){
    guard let obstaclesTileMap = obstaclesTileMap else { return }
         // 1
         for row in 0..<obstaclesTileMap.numberOfRows {
           for column in 0..<obstaclesTileMap.numberOfColumns {
             // 2
             guard let tile = tile(in: obstaclesTileMap,
                                   at: (column, row))
               else { continue }
             guard tile.userData?.object(forKey: "zappable") != nil
                     else { continue }
                   // 3
                   let node = SKNode()
                   node.physicsBody = SKPhysicsBody(rectangleOf: tile.size)
                   node.physicsBody?.isDynamic = false
                   node.physicsBody?.friction = 0
                   node.physicsBody?.categoryBitMask =
                     PhysicsCategory.Zappable

                   node.position = obstaclesTileMap.centerOfTile(
                     atColumn: column, row: row)
                   obstaclesTileMap.addChild(node)
               }
            }
  }
  
  func setupChoppableTilePhysics(){
    guard let obstaclesTileMap = obstaclesTileMap else { return }
    // 1
    for row in 0..<obstaclesTileMap.numberOfRows {
      for column in 0..<obstaclesTileMap.numberOfColumns {
        // 2
        guard let tile = tile(in: obstaclesTileMap,
                              at: (column, row))
          else { continue }
        guard tile.userData?.object(forKey: "choppable") != nil
                else { continue }
              // 3
              let node = SKNode()
              node.physicsBody = SKPhysicsBody(rectangleOf: tile.size)
              node.physicsBody?.isDynamic = false
              node.physicsBody?.friction = 0
              node.physicsBody?.categoryBitMask =
                PhysicsCategory.Choppable

              node.position = obstaclesTileMap.centerOfTile(
                atColumn: column, row: row)
              obstaclesTileMap.addChild(node)
          }
       }
  }
  
  func setupWashableTilePhysics() {
    guard let washableTileMap = background else { return }
    // 1
    for row in 0..<washableTileMap.numberOfRows {
      for column in 0..<washableTileMap.numberOfColumns {
        // 2
        guard let tile = tile(in: washableTileMap,
                              at: (column, row))
          else { continue }
        guard tile.userData?.object(forKey: "washable") != nil
                else { continue }
              // 3
              let node = SKNode()
                node.physicsBody = SKPhysicsBody(rectangleOf: tile.size)
                node.physicsBody?.isDynamic = false
                node.physicsBody?.friction = 0
                node.physicsBody?.categoryBitMask =
                PhysicsCategory.Washable

              node.position = washableTileMap.centerOfTile(
                atColumn: column, row: row)
              washableTileMap.addChild(node)
          }
       }
  }
  
  
  
  func tileGroupForName(tileSet: SKTileSet, name: String) -> SKTileGroup?{
    let tileGroup = tileSet.tileGroups.filter{$0.name == name}.first
    return tileGroup
  }
  
  func advanceBreakableTile(locatedAt nodePosition: CGPoint){
    guard let obstaclesTileMap = obstaclesTileMap else {
      return
    }
    let (column, row) = tileCoordinates(in: obstaclesTileMap, at: nodePosition)
    
    let obstacle = tile(in: obstaclesTileMap, at: (column, row))
    
    guard let nextTileGroupName = obstacle?.userData?.object(forKey: "breakable") as? String else{
      return
    }
    if let nextTileGroup = tileGroupForName(tileSet: obstaclesTileMap.tileSet, name: nextTileGroupName) {
        obstaclesTileMap.setTileGroup(nextTileGroup, forColumn: column, row: row)
      }
  }
  
  func advanceChoppableTile(locatedAt nodePosition: CGPoint){
    guard let obstaclesTileMap = obstaclesTileMap else {
      return
    }
    let (column, row) = tileCoordinates(in: obstaclesTileMap, at: nodePosition)
    
    let obstacle = tile(in: obstaclesTileMap, at: (column, row))
    
    guard let nextTileGroupName = obstacle?.userData?.object(forKey: "choppable") as? String else{
      return
    }
    if let nextTileGroup = tileGroupForName(tileSet: obstaclesTileMap.tileSet, name: nextTileGroupName) {
        obstaclesTileMap.setTileGroup(nextTileGroup, forColumn: column, row: row)
      }
  }
  
  
  func tileCoordinates(in tileMap: SKTileMapNode, at position: CGPoint) -> TileCoordinates{
    let column = tileMap.tileColumnIndex(fromPosition: position)
    let row = tileMap.tileRowIndex(fromPosition: position)
    
    return (column, row)
  }
  

  func createBugspray(quantity: Int){
    let tile = SKTileDefinition(texture: SKTexture(pixelImageNamed: "bugspray"))
    
    let tilerule = SKTileGroupRule(adjacency: SKTileAdjacencyMask.adjacencyAll, tileDefinitions: [tile])
    
    let tilegroup = SKTileGroup(rules: [tilerule])
    
    let tileset = SKTileSet(tileGroups: [tilegroup])
    
    let columns = background.numberOfColumns
    let rows = background.numberOfRows
    bugsprayTileMap = SKTileMapNode(tileSet: tileset, columns: columns, rows: rows, tileSize: tile.size)
    
    for _ in 1...quantity {
      let column = Int.random(min: 0, max: columns - 1)
      let row = Int.random(min: 0, max: rows - 1)
      bugsprayTileMap?.setTileGroup(tilegroup, forColumn: column, row: row)
    }
    
    bugsprayTileMap?.name = "Bugspray"
    
    addChild(bugsprayTileMap!)
  }
  
  
  
  func updateBugspray(){
    guard let bugsprayTileMap = bugsprayTileMap else {return}
    let (column, row) = tileCoordinates(in: bugsprayTileMap, at: player.position)
    
    if tile(in: bugsprayTileMap, at: (column, row)) != nil {
      bugsprayTileMap.setTileGroup(nil, forColumn: column, row: row)
      player.hasBugspray = true
      
    }
  }
  
  func createFireElement(quantity: Int){
    let tile = SKTileDefinition(texture: SKTexture(pixelImageNamed: "flame"))
    
    let tilerule = SKTileGroupRule(adjacency: SKTileAdjacencyMask.adjacencyAll, tileDefinitions: [tile])
    
    let tilegroup = SKTileGroup(rules: [tilerule])
    
    let tileset = SKTileSet(tileGroups: [tilegroup])
    
    let columns = background.numberOfColumns
    let rows = background.numberOfRows
    fireElementTileMap = SKTileMapNode(tileSet: tileset, columns: columns, rows: rows, tileSize: tile.size)
    
    for _ in 1...quantity {
      let column = Int.random(min: 0, max: columns - 1)
      let row = Int.random(min: 0, max: rows - 1)
      fireElementTileMap?.setTileGroup(tilegroup, forColumn: column, row: row)
    }
    
    fireElementTileMap?.name = "Flame"
    
    addChild(fireElementTileMap!)
  }
  
  
  
  func updateFireElement(){
    guard let fireElementTileMap = fireElementTileMap else {return}
    let (column, row) = tileCoordinates(in: fireElementTileMap, at: player.position)
    
    if tile(in: fireElementTileMap, at: (column, row)) != nil && player.hasBugspray {
      fireElementTileMap.setTileGroup(nil, forColumn: column, row: row)
      player.hasFireElement = true
      
    }
  }
  
  override func update(_ currentTime: TimeInterval) {
    
    
    if gameState != .play {
      isPaused = true
      return
    }
  
    if !player.hasBugspray{
      updateBugspray()
    }
    
    if !player.hasFireElement{
      updateFireElement()
    }
    
    if player.hasThunderElement && player.hasWaterElement && player.hasGrassElement && player.hasFireElement && player.hasRockElement && player.hasBugspray && megaBugCount > 0 {

      player.hasFireElement = false
      player.hasWaterElement = false
      player.hasGrassElement = false
      player.hasRockElement = false
      player.hasThunderElement = false
      player.hasEveryElement = true
    }
    
    advanceBreakableTile(locatedAt: player.position)
    advanceChoppableTile(locatedAt: player.position)
    updateHUD(currentTime: currentTime)
    checkEndGame()
  }
  
}


/////////////////////////////////////////////////////////////////////////////////////////////////
extension GameScene: SKPhysicsContactDelegate{
  func remove(bug: Bug){
    bug.removeFromParent()
    background.addChild(bug)
    bug.die()
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    let other = contact.bodyA.categoryBitMask
      == PhysicsCategory.Player ?
        contact.bodyB : contact.bodyA
      
    switch other.categoryBitMask {
    case PhysicsCategory.Bug:
      if let bug = other.node as? Bug {
        remove(bug: bug)
        normalBugCount -= 1
      }
      
    case PhysicsCategory.Firebug:
      if player.hasBugspray && player.hasFireElement || player.hasEveryElement {
        if let firebug = other.node as? Firebug {
          remove(bug: firebug)
          player.hasBugspray = false
          player.hasFireElement = false
          fireBugCount -= 1
        }
      }
    case PhysicsCategory.Breakable:
      if let obstacleNode = other.node {
        advanceBreakableTile(locatedAt: obstacleNode.position)
        
        obstacleNode.removeFromParent()
        
        if rockBugCount > 0 &&  player.hasBugspray && !player.hasRockElement || megaBugCount > 0 && player.hasBugspray && !player.hasRockElement  {
          player.hasRockElement = true
        }
        
      }
    case PhysicsCategory.Choppable:
      if let obstacleNode = other.node{
        advanceChoppableTile(locatedAt: obstacleNode.position)
        obstacleNode.removeFromParent()
        
        if grassBugCount > 0  && player.hasBugspray && !player.hasGrassElement || megaBugCount > 0 && player.hasBugspray && !player.hasGrassElement {
          player.hasGrassElement = true
          
        }
      }
    case PhysicsCategory.Washable:
        if other.node != nil {
          if player.hasBugspray && waterBugCount > 0 && !player.hasWaterElement || megaBugCount > 0 && player.hasBugspray && !player.hasWaterElement {
              player.hasWaterElement = true
              
          }
        }
    case PhysicsCategory.Zappable:
      if other.node != nil {
        if player.hasBugspray && thunderBugCount > 0 && !player.hasThunderElement || megaBugCount > 0 && player.hasBugspray && !player.hasThunderElement {
          player.hasThunderElement = true
        }
      }
    case PhysicsCategory.Waterbug:
      if player.hasBugspray && player.hasWaterElement || player.hasEveryElement {
        if let waterbug = other.node as? Waterbug {
          remove(bug: waterbug)
          player.hasBugspray = false
          player.hasWaterElement = false
          waterBugCount -= 1
        }
      }
    case PhysicsCategory.Grassbug:
      if player.hasBugspray && player.hasGrassElement || player.hasEveryElement {
        if let grassbug = other.node as? Grassbug {
          remove(bug: grassbug)
          player.hasBugspray = false
          player.hasGrassElement = false
          grassBugCount -= 1
        }
      }
    case PhysicsCategory.Rockbug:
      if player.hasBugspray && player.hasRockElement || player.hasEveryElement {
           if let rockbug = other.node as? Rockbug {
             remove(bug: rockbug)
             player.hasBugspray = false
             player.hasRockElement = false
             rockBugCount -= 1
             }
           }
    case PhysicsCategory.Thunderbug:
      if player.hasBugspray && player.hasThunderElement || player.hasEveryElement {
        if let thunderbug = other.node as? Thunderbug {
          remove(bug: thunderbug)
          player.hasBugspray = false
          player.hasThunderElement = false
          thunderBugCount -= 1
        }
      }
    case PhysicsCategory.Megabug:
      if player.hasBugspray && player.hasEveryElement {
          if let megabug = other.node as? Megabug {
            remove(bug: megabug)
            player.hasBugspray = false
            player.hasEveryElement = false
            megaBugCount -= 1
            }
          }
    default:
      break
    }
    
    if let physicsBody = player.physicsBody {
      if physicsBody.velocity.length() > 0 {
        player.checkDirection()
      }
    }
  }
}


// MARK - Notifications
extension GameScene {
  func applicationDidBecomeActive(){
    print("* applicationDidBecomeActive")
    if gameState == .pause{
      gameState = .reload
    }
  }
  
  func applicationWillResignActive(){
    print("* applicationWillResignActive")
    if gameState != .lose{
      gameState = .pause
    }
  }
  
  func applicationDidEnterBackground(){
    print("* applicationDidEnterBackground")
    if gameState != .lose{
      saveGame()
    }
  }
  
  func addObservers() {
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(forName: .UIApplicationDidBecomeActive, object: nil, queue: nil) { [weak self] _ in
        self?.applicationDidBecomeActive()
    }
    notificationCenter.addObserver(forName: .UIApplicationWillResignActive, object: nil, queue: nil) { [weak self] _ in
        self?.applicationWillResignActive()
    }
    notificationCenter.addObserver(forName: .UIApplicationDidEnterBackground, object: nil, queue: nil) { [weak self] _ in
        self?.applicationDidEnterBackground()
    }
  }
}

// MARK - Saving Games
extension GameScene {
  
  func saveGame(){
  let fileManager = FileManager.default
  guard let directory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first
  else{return}
    
    let saveURL = directory.appendingPathComponent("SavedGames")
  
  do{
  try fileManager.createDirectory(atPath: saveURL.path, withIntermediateDirectories: true, attributes: nil)
  }catch let error as NSError{
    fatalError("Failed to create a directory: \(error.debugDescription)")
  }
    
    let fileURL = saveURL.appendingPathComponent("saved-game")
    print("* Saving: \(fileURL.path)")
    
    NSKeyedArchiver.archiveRootObject(self, toFile: fileURL.path)
 }
  
  override func encode(with aCoder: NSCoder){
    aCoder.encode(fireBugCount, forKey: "Scene.firebugCount")
    aCoder.encode(elapsedTime, forKey: "Scene.elapsedTime")
    aCoder.encode(gameState.rawValue, forKey: "Scene.gameState")
    aCoder.encode(currentLevel, forKey: "Scene.currentLevel")
    super.encode(with: aCoder)
  }
  
  class func loadGame() -> SKScene? {
    print("* loading game")
    var scene: SKScene?
    
    let fileManager = FileManager.default
    guard let directory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else{
      return nil
    }
    let url = directory.appendingPathComponent("SavedGames/saved-game")
    
    if FileManager.default.fileExists(atPath: url.path){
      scene = NSKeyedUnarchiver.unarchiveObject(withFile: url.path) as? GameScene
      
      _ = try? fileManager.removeItem(at: url)
    }
    return scene
  }
}


