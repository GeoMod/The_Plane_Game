//
//  GameScene.swift
//  The Plane Game
//
//  Created by Daniel O'Leary on 8/2/19.
//  Copyright © 2019 Impulse Coupled Dev. All rights reserved.
//

import CoreMotion
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print(">>> Game Sfene INIT")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        print(">>> Other kind of init")
    }
    
    deinit {
        print(">>> GAME SCENE DEINIT")
    }
    weak var viewController: GameViewController!
//    var motionManager: CMMotionManager!
    let motionManager = CMMotionManager()
    var scoreDelegate: AdjustScoreDelegate!
    
    var player = SKSpriteNode(imageNamed: "airplane")
    
    var airplaneAcceleration = CGVector(dx: 0, dy: 0)
    let maxPlayerSpeed: CGFloat = 200
    let maxPlayerAcceleration: CGFloat = 400
    var accelerometerXYZ = CMAcceleration(x: 0, y: 0, z: 0)
    
    var playerVelocity = CGVector(dx: 0, dy: 0)
    var lastUpdateTime: CFTimeInterval = 0
    var direction = SIMD2<Float>(x: 0, y: 0)
    
    var playerLastKnownPosition = CGPoint()
    
    let degreesToRadians = CGFloat.pi / 180
    let radiansToDegrees = 180 / CGFloat.pi
    
    
    var directionAngle: CGFloat = 0.0 {
        didSet {
            if directionAngle != oldValue {
                // action that rotates the node to an angle expressed in radian.
                let action = SKAction.rotate(toAngle: directionAngle, duration: 0.1, shortestUnitArc: true)
                run(action)
            }
        }
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
//        motionManager = CMMotionManager()
        scoreDelegate = Score()
    }
    
    func loadAirplane(at position: CGPoint, addToScene: Bool) {
        player.position = position
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.categoryBitMask = CollisionTypes.airplane.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.deadTree.rawValue | CollisionTypes.liveTree.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.deadTree.rawValue | CollisionTypes.liveTree.rawValue
        player.physicsBody?.isDynamic = true
        player.physicsBody?.linearDamping = 0.5
        
        if addToScene {
            addChild(player)
        } else {
            return
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        let deltaTime = max(1.0/30, currentTime - lastUpdateTime)
        lastUpdateTime = currentTime
        
        updatePlayerAccelerationFromMotionManager()
        updatePlayer(deltaTime)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }
    
    // MARK: - Updating Player Score & Lives
    func playerCollided(with node: SKNode) {
        if node.name == "runway" {
            // Consider making the number of points added = the number of seconds remaining on the timer
            scoreDelegate.updateScore(amount: 100)
            scoreDelegate.updateLevel(amount: 1)
            viewController.scoreLabel.text = "Score: \(Score.currentScore)"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.player.removeFromParent()
                switch Score.currentLevel {
                case 1:
                    // Load level 2
                    print("Load Level2")
                    
                    if let scene = SKScene(fileNamed: "LevelTwo") as? GameScene {
                        scene.scaleMode = .aspectFill
                        scene.viewController = self.viewController
                        self.viewController?.gameScene = scene
                        self.view?.presentScene(scene, transition: .fade(withDuration: 1.0))
                    }
                case 2:
                    // Load Level 3
                    print("Load Level3")
                    let newGame = GameScene(size: self.size)
                    newGame.viewController = self.viewController
                    self.viewController.gameScene = newGame
                    
                    if let scene = SKScene(fileNamed: "LevelOne") {
                        scene.scaleMode = .aspectFill
                        self.view?.presentScene(scene, transition: .flipVertical(withDuration: 0.5))
                    }
                default:
                    print("Default")
                }
                
                self.viewController.centerStartButtonTitle.setTitle("Tap To Start", for: .normal)
                // Ensures game state is maintained at the scene transition.
                self.viewController.isGamePlaying = false

            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.viewController.centerStartButtonTitle.isHidden = false
                self.viewController.playPauseButtonTitle.isHidden = true
            }
            return
        } else if node.name == "deadTree" || node.name == "liveTree" {
            if let fireExplosion = SKEmitterNode(fileNamed: "TowerFireExplosion") {
                fireExplosion.position = player.position
                addChild(fireExplosion)
                update(-100)
                viewController.scoreLabel.text = "Score: \(Score.currentScore)"
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    if let treeFire = SKEmitterNode(fileNamed: "TreeFire") {
                        treeFire.position = node.position
                        self.addChild(treeFire)
                    }
                }
            }
        } else if node.name == "leftRunwayEdge" || node.name == "rightRunwayEdge" {
            if let groundImpact = SKEmitterNode(fileNamed: "GroundImpact") {
                groundImpact.position = player.position
                addChild(groundImpact)
                scoreDelegate.updateScore(amount: -100)
                viewController.scoreLabel.text = "Score: \(Score.currentScore)"
            }
        }
        player.removeFromParent()
        if Score.playerLives > 0 {
            scoreDelegate.updateLives(amount: -1)
            viewController.livesLabel.text = "Lives: \(Score.playerLives)"
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                self.loadAirplane(at: self.viewController.planeStartingPosition, addToScene: true)
//            }
        } else if Score.playerLives == 0 {
            viewController.centerStartButtonTitle.setTitle("Game Over", for: .normal)
            viewController.centerStartButtonTitle.isHidden = false
            Score.currentScore = 0
            Score.playerLives = 3
            Score.currentLevel = 1
            
            // Reset lives and score labels.
            viewController.scoreLabel.text = "Score: \(Score.currentScore)"
            viewController.livesLabel.text = "Lives: \(Score.playerLives)"
        }
    }
    
    
    // MARK: - Player acceleration
    func updatePlayerAccelerationFromMotionManager() {
        guard let acceleration = motionManager.accelerometerData?.acceleration else { return }
        let filterFactor = 0.9

        accelerometerXYZ.x = acceleration.x * filterFactor + accelerometerXYZ.x * (1 - filterFactor)
        accelerometerXYZ.y = acceleration.y * filterFactor + accelerometerXYZ.y * (1 - filterFactor)

        airplaneAcceleration.dx = CGFloat(accelerometerXYZ.y) * -maxPlayerAcceleration
        airplaneAcceleration.dy = CGFloat(accelerometerXYZ.x) * maxPlayerAcceleration
    }
    
    func updatePlayer(_ dt: CFTimeInterval) {
        playerVelocity.dx = playerVelocity.dx + airplaneAcceleration.dx * CGFloat(dt)
        playerVelocity.dy = playerVelocity.dy + airplaneAcceleration.dy * CGFloat(dt)

        playerVelocity.dx = max(-maxPlayerSpeed, min(maxPlayerSpeed, playerVelocity.dx))
        playerVelocity.dy = max(-maxPlayerSpeed, min(maxPlayerSpeed, playerVelocity.dy))

        var newX = player.position.x + playerVelocity.dx * CGFloat(dt)
        var newY = player.position.y + playerVelocity.dy * CGFloat(dt)

        newX = min(size.width, max(0, newX))
        newY = min(size.height, max(0, newY))

        player.position = CGPoint(x: newX, y: newY)
        playerLastKnownPosition = player.position

        let angle = atan2(playerVelocity.dy, playerVelocity.dx)
        player.zRotation = angle - 90 * degreesToRadians
    }
    
}
