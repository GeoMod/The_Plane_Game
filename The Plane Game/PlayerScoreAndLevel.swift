//
//  PlayerScoreAndLevel.swift
//  The Plane Game
//
//  Created by Daniel O'Leary on 8/3/19.
//  Copyright © 2019 Impulse Coupled Dev. All rights reserved.
//


protocol AdjustScoreDelegate {
    func update(score: Int)
    func update(level: Int)
    func update(lives: Int)
    
    var currentLevel: Int { get set}
    var playerLives: Int { get set }
    var currentScore: Int { get set }
}

class ScoreAndLevel: AdjustScoreDelegate {
    var currentLevel = 1
    var playerLives = 3
    var currentScore = 0
        
    func update(level: Int) {
        currentLevel += level
    }
    
    func update(lives: Int) {
        playerLives += lives
    }
    
    func update(score: Int) {
        currentScore += score
    }
}
