//
//  Acceleration.swift
//  The Plane Game
//
//  Created by Daniel O'Leary on 8/12/19.
//  Copyright © 2019 Impulse Coupled Dev. All rights reserved.
//

import SpriteKit
import CoreMotion

protocol UpdateAcceleration {
    func updatePlayerAccelerationFromMotionManager()
    func update(player: SKSpriteNode,at timeInterval: CFTimeInterval)
}

class Acceleration: SKScene, SKPhysicsContactDelegate, UpdateAcceleration {
    var motionManager = CMMotionManager()
    
    var playerAcceleration = CGVector(dx: 0, dy: 0)
    let maxPlayerSpeed: CGFloat = 200
    let maxPlayerAcceleration: CGFloat = 400
    var accelerometerXYZ = CMAcceleration(x: 0, y: 0, z: 0)
    
    var playerVelocity = CGVector(dx: 0, dy: 0)
    
    var playerLastKnownPosition = CGPoint()
    
    let degreesToRadians = CGFloat.pi / 180
    
    func updatePlayerAccelerationFromMotionManager() {
        guard let acceleration = motionManager.accelerometerData?.acceleration else { return }
        let filterFactor = 0.9

        accelerometerXYZ.x = acceleration.x * filterFactor + accelerometerXYZ.x * (1 - filterFactor)
        accelerometerXYZ.y = acceleration.y * filterFactor + accelerometerXYZ.y * (1 - filterFactor)

        playerAcceleration.dx = CGFloat(accelerometerXYZ.y) * -maxPlayerAcceleration
        playerAcceleration.dy = CGFloat(accelerometerXYZ.x) * maxPlayerAcceleration
        
    }
    
    func update(player: SKSpriteNode,at timeInterval: CFTimeInterval) {
        playerVelocity.dx = playerVelocity.dx + playerAcceleration.dx * CGFloat(timeInterval)
        playerVelocity.dy = playerVelocity.dy + playerAcceleration.dy * CGFloat(timeInterval)
        
        playerVelocity.dx = max(-maxPlayerSpeed, min(maxPlayerSpeed, playerVelocity.dx))
        playerVelocity.dy = max(-maxPlayerSpeed, min(maxPlayerSpeed, playerVelocity.dy))
        
        var newX = player.position.x + playerVelocity.dx * CGFloat(timeInterval)
        var newY = player.position.y + playerVelocity.dy * CGFloat(timeInterval)
        
        newX = min(size.width, max(0, newX))
        newY = min(size.height, max(0, newY))
        
        player.position = CGPoint(x: newX, y: newY)
        playerLastKnownPosition = player.position
        
        let angle = atan2(playerVelocity.dy, playerVelocity.dx)
        player.zRotation = angle - 90 * degreesToRadians
    }
}
