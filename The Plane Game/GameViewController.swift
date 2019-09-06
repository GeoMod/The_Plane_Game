//
//  GameViewController.swift
//  The Plane Game
//
//  Created by Daniel O'Leary on 8/2/19.
//  Copyright © 2019 Impulse Coupled Dev. All rights reserved.
//

import SpriteKit
import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var livesLabel: UILabel!
    @IBOutlet weak var playPauseButtonTitle: UIButton!
    @IBOutlet weak var centerStartButtonTitle: UIButton!
    
    var scoreDelegate: AdjustScoreDelegate!
    var gameScene: GameScene!
    
    var isGamePlaying = false
    
    let planeStartingPosition = CGPoint(x: 819, y: 181)

    override func viewDidLoad() {
        super.viewDidLoad()
        scoreDelegate = Score()
        
        centerStartButtonTitle.setTitle("Tap to Play", for: .normal)
        loadLevel()
    }
    
    // Load the scene and level
    func loadLevel() {
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "LevelOne") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                gameScene = scene as? GameScene
                gameScene.viewController = self
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    
    @IBAction func playPauseTapped(_ sender: UIButton) {
        switch isGamePlaying {
        case false:
            // Game is paused but we want to start/resume the game.
            beginGamePlay()
        case true:
            // Game is running but we want to pause.
            // Use in iOS13
//            playPauseButtonTitle.setBackgroundImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            centerStartButtonTitle.setTitle("Paused", for: .normal)
            centerStartButtonTitle.isHidden = false
            view.alpha = 0.5
            gameScene.player.removeFromParent()
            gameScene.player.position = gameScene.playerLastKnownPosition
            gameScene.motionManager.stopAccelerometerUpdates()
            gameScene.isPaused = true
            isGamePlaying.toggle()
            // Implement timer...then stop timer here.
        }
    }
    
    @IBAction func centerStartTapped(_ sender: UIButton) {
        beginGamePlay()
    }
    
    func beginGamePlay() {
        // Use in iOS13
//        playPauseButtonTitle.setBackgroundImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
        playPauseButtonTitle.isHidden = false
        
        centerStartButtonTitle.isHidden = true
        centerStartButtonTitle.setTitle("Paused", for: .normal)
        view.alpha = 1.0
        
        gameScene.loadAirplane(at: planeStartingPosition, addToScene: true)
        gameScene.isPaused = false
        gameScene.motionManager.startAccelerometerUpdates()
        isGamePlaying.toggle()
    }
    
    
    // MARK: - Updating Player Score & Lives
        func playerCollided(with node: SKNode) {
            if node.name == "runway" {
                // Consider making the number of points added = the number of seconds remaining on the timer
                scoreDelegate.updateScore(amount: 100)
                scoreDelegate.updateLevel(amount: 1)
                scoreLabel.text = "Score: \(Score.currentScore)"
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.gameScene.player.removeFromParent()
                    switch Score.currentLevel {
                    case 2:
                        // Load level 2
                        print("Load Level2")
                        if let scene = SKScene(fileNamed: "LevelTwo") as? GameScene {
                            // Refactor this out into its own method since it will be repeated for each scene.
                            scene.scaleMode = .aspectFill
                            self.gameScene.view?.presentScene(scene, transition: .fade(withDuration: 1.0))
                            scene.viewController = self
                            self.gameScene = scene
                        }
                    case 3:
                        // Load Level 3
                        self.scoreDelegate.updateLevel(amount: -1)
                        // Loop back to level 1 for testing purposes
                        if let scene = SKScene(fileNamed: "LevelOne") as? GameScene {
                            scene.scaleMode = .aspectFill
                            self.gameScene.view?.presentScene(scene, transition: .flipVertical(withDuration: 0.5))
                            scene.viewController = self
                            self.gameScene = scene
                        }
                    default:
                        print("Default")
                    }
                    self.centerStartButtonTitle.setTitle("Tap To Play", for: .normal)
                    self.isGamePlaying = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.centerStartButtonTitle.isHidden = false
                    self.playPauseButtonTitle.isHidden = true
                }
                return
            } else if node.name == "deadTree" || node.name == "liveTree" {
                if let fireExplosion = SKEmitterNode(fileNamed: "TowerFireExplosion") {
                    fireExplosion.position = gameScene.player.position
                    gameScene.addChild(fireExplosion)
                    gameScene.update(-100)
                    scoreLabel.text = "Score: \(Score.currentScore)"
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        if let treeFire = SKEmitterNode(fileNamed: "TreeFire") {
                            treeFire.position = node.position
                            self.gameScene.addChild(treeFire)
                        }
                    }
                }
            } else if node.name == "leftRunwayEdge" || node.name == "rightRunwayEdge" {
                if let groundImpact = SKEmitterNode(fileNamed: "GroundImpact") {
                    groundImpact.position = gameScene.player.position
                    gameScene.addChild(groundImpact)
                    scoreDelegate.updateScore(amount: -100)
                    scoreLabel.text = "Score: \(Score.currentScore)"
                }
            }
            gameScene.player.removeFromParent()
            if Score.playerLives > 0 {
                scoreDelegate.updateLives(amount: -1)
                livesLabel.text = "Lives: \(Score.playerLives)"
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.gameScene.loadAirplane(at: self.planeStartingPosition, addToScene: true)
                }
            } else if Score.playerLives == 0 {
                centerStartButtonTitle.setTitle("Game Over", for: .normal)
                centerStartButtonTitle.isHidden = false
                Score.currentScore = 0
                Score.playerLives = 3
                Score.currentLevel = 1
                
                // Reset lives and score labels.
                scoreLabel.text = "Score: \(Score.currentScore)"
                livesLabel.text = "Lives: \(Score.playerLives)"
            }
        }
    
    

    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
