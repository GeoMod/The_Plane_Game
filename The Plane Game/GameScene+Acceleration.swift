//
//  Acceleration.swift
//  The Plane Game
//
//  Created by Daniel O'Leary on 8/12/19.
//  Copyright © 2019 Impulse Coupled Dev. All rights reserved.
//

import SpriteKit
import CoreMotion

extension GameScene: SKPhysicsContactDelegate {
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
