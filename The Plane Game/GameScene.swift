//
//  GameScene.swift
//  The Plane Game
//
//  Created by Daniel O'Leary on 8/2/19.
//  Copyright © 2019 Impulse Coupled Dev. All rights reserved.
//

import CoreMotion
import SpriteKit

class GameScene: SKScene {
    
    // Used in Debugging to ensure scene's are being regenerated.
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        print(">>> Game Scene INIT")
//    }
//
//    override init(size: CGSize) {
//        super.init(size: size)
//        print(">>> Other kind of init")
//    }
//
//    deinit {
//        print(">>> GAME SCENE DEINIT")
//    }
    weak var viewController: GameViewController!
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
            viewController.playerCollided(with: nodeB)
        } else if nodeB == player {
            viewController.playerCollided(with: nodeA)
        }
    }
    
    
}
