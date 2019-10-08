//
//  CollisionTypes.swift
//  The Plane Game
//
//  Created by Daniel O'Leary on 8/3/19.
//  Copyright © 2019 Impulse Coupled Dev. All rights reserved.
//


import SpriteKit

enum CollisionTypes: UInt32 {
    case airplane = 1
    case runwayEdge = 2
    case tower = 4 // Unused
    case runwaysurface = 8
    case liveTree = 16
    case deadTree = 32
    case wall = 64
}


protocol AdjustScoreDelegate {
    func moveTo(level: Int)
    func updateLives(amount: Int)
}


struct Score: AdjustScoreDelegate {
    static var currentLevel = 1
    static var playerLives = 3
        
    func moveTo(level: Int) {
        Score.currentLevel = level
    }
    
    func updateLives(amount: Int) {
        Score.playerLives += amount
    }
}
