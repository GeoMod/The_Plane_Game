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


struct StartingPositions {
    let level1 = CGPoint(x: 819, y: 181)
}


protocol AdjustScoreDelegate {
    func updateScore(amount: Int)
    func updateLevel(amount: Int)
    func updateLives(amount: Int)
}


struct ScoreAndLevel: AdjustScoreDelegate {
    static var currentLevel = 1
    static var playerLives = 3
    static var currentScore = 0
        
    func updateLevel(amount: Int) {
        ScoreAndLevel.currentLevel += amount
    }
    
    func updateLives(amount: Int) {
        ScoreAndLevel.playerLives += amount
    }
    
    func updateScore(amount: Int) {
        ScoreAndLevel.currentScore += amount
    }
}
