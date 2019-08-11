//
//  GameScene.swift
//  The Plane Game
//
//  Created by Daniel O'Leary on 8/2/19.
//  Copyright © 2019 Impulse Coupled Dev. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    weak var viewController: GameViewController!
    var motionManager = CMMotionManager()
    var airplane = SKSpriteNode(imageNamed: "airplane")
    var background: SKSpriteNode!
    var deadTrees = [SKSpriteNode]()
    var liveTrees = [SKSpriteNode]()
    
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
    
    let playerDelegate = ScoreAndLevel()
    
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
        
        background = childNode(withName: "background") as? SKSpriteNode
        
        for tree in children {
            if tree.name == "deadTree" {
                if let tree = tree as? SKSpriteNode {
                    deadTrees.append(tree)
                }
            } else if tree.name == "liveTree" {
                if let tree = tree as? SKSpriteNode {
                    liveTrees.append(tree)
                }
            }
        }
    }
    
    func loadAirplane(at position: CGPoint, addToScene: Bool) {
        airplane.position = position
        airplane.zPosition = 1
        airplane.physicsBody = SKPhysicsBody(circleOfRadius: airplane.size.width / 2)
        airplane.physicsBody?.categoryBitMask = CollisionTypes.airplane.rawValue
        airplane.physicsBody?.contactTestBitMask = CollisionTypes.deadTree.rawValue | CollisionTypes.liveTree.rawValue
        airplane.physicsBody?.collisionBitMask = CollisionTypes.deadTree.rawValue | CollisionTypes.liveTree.rawValue
        airplane.physicsBody?.isDynamic = true
        airplane.physicsBody?.linearDamping = 0.5
        
        if addToScene {
            addChild(airplane)
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
        
        if nodeA == airplane {
            playerCollided(with: nodeB)
        } else if nodeB == airplane {
            playerCollided(with: nodeA)
        }
    }
    
    // MARK: - Updating Player Score & Lives
    func playerCollided(with node: SKNode) {
        if node.name == "runway" {
            // Consider making the number of points added = the number of seconds remaining on the timer
            playerDelegate.update(score: 100)
            playerDelegate.update(level: 1)
            viewController.scoreLabel.text = "Score: \(playerDelegate.currentScore)"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let nextLevel = GameScene(size: self.size)  
                nextLevel.viewController = self.viewController
                self.viewController.gameScene = nextLevel
                
                let transition = SKTransition.doorway(withDuration: 1.0)
                self.view?.presentScene(nextLevel, transition: transition)
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
                fireExplosion.position = airplane.position
                addChild(fireExplosion)
                playerDelegate.update(score: -100)
                viewController.scoreLabel.text = "Score: \(playerDelegate.currentScore)"
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    if let treeFire = SKEmitterNode(fileNamed: "TreeFire") {
                        treeFire.position = node.position
                        self.addChild(treeFire)
                    }
                }
            }
        } else if node.name == "leftRunwayEdge" || node.name == "rightRunwayEdge" {
            if let groundImpact = SKEmitterNode(fileNamed: "GroundImpact") {
                groundImpact.position = airplane.position
                addChild(groundImpact)
                playerDelegate.update(score: -100)
                viewController.scoreLabel.text = "Score: \(playerDelegate.currentScore)"
            }
        }
        airplane.removeFromParent()
        if playerDelegate.playerLives > 0 {
            playerDelegate.update(lives: -1)
            viewController.livesLabel.text = "Lives: \(playerDelegate.playerLives)"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.loadAirplane(at: self.viewController.planePosition.level1, addToScene: true)
            }
        } else if playerDelegate.playerLives == 0 {
            viewController.centerStartButtonTitle.setTitle("Game Over", for: .normal)
            viewController.centerStartButtonTitle.isHidden = false
            playerDelegate.currentScore = 0
            playerDelegate.playerLives = 3
            playerDelegate.currentLevel = 1
            
            // Reset lives and score labels.
            viewController.scoreLabel.text = "Score: \(playerDelegate.currentScore)"
            viewController.livesLabel.text = "Lives: \(playerDelegate.playerLives)"
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
        
        var newX = airplane.position.x + playerVelocity.dx * CGFloat(dt)
        var newY = airplane.position.y + playerVelocity.dy * CGFloat(dt)
        
        newX = min(size.width, max(0, newX))
        newY = min(size.height, max(0, newY))
        
        airplane.position = CGPoint(x: newX, y: newY)
        playerLastKnownPosition = airplane.position
        
        let angle = atan2(playerVelocity.dy, playerVelocity.dx)
        airplane.zRotation = angle - 90 * degreesToRadians
    }
    
}
