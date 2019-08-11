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
    func update(score: Int)
    func update(level: Int)
    func update(lives: Int)
    
    var currentLevel: Int { get set }
    var playerLives: Int { get set }
    var currentScore: Int { get set }
}


class ScoreAndLevel: AdjustScoreDelegate {
    var currentLevel = 1
    var playerLives = 3
    var currentScore = 0
    
    let defaults = UserDefaults.standard
        
    func update(level: Int) {
        currentLevel += level
        defaults.set(currentScore, forKey: "level")
    }
    
    func update(lives: Int) {
        playerLives += lives
    }
    
    func update(score: Int) {
        currentScore += score
    }
}
