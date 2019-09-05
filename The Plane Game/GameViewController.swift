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
    

    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
