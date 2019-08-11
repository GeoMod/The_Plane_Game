//
//  GameViewController.swift
//  The Plane Game
//
//  Created by Daniel O'Leary on 8/2/19.
//  Copyright © 2019 Impulse Coupled Dev. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var livesLabel: UILabel!
    @IBOutlet weak var playPauseButtonTitle: UIButton!
    @IBOutlet weak var centerStartButtonTitle: UIButton!
    
    var isGamePlaying = false
    var gameScene: GameScene!
    
    let levelTracker = ScoreAndLevel()
    let planePosition = StartingPositions()
    
    
    let level1 = CGPoint(x: 819, y: 181)
    // Define later levels.
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        centerStartButtonTitle.setTitle("Tap to Play", for: .normal)
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "Level" + String(levelTracker.currentLevel)) {
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
            
            #warning("iOS13")
//            playPauseButtonTitle.setBackgroundImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            centerStartButtonTitle.setTitle("Paused", for: .normal)
            centerStartButtonTitle.isHidden = false
            view.alpha = 0.5
            gameScene.airplane.removeFromParent()
            gameScene.airplane.position = gameScene.playerLastKnownPosition
            gameScene.motionManager.stopAccelerometerUpdates()
            isGamePlaying.toggle()
            
            // Implement timer...then stop timer here.
        }
    }
    
    @IBAction func centerStartTapped(_ sender: UIButton) {
        beginGamePlay()
    }
    
    func beginGamePlay() {
        #warning("iOS13")
//        playPauseButtonTitle.setBackgroundImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
        playPauseButtonTitle.isHidden = false
        
        centerStartButtonTitle.isHidden = true
        centerStartButtonTitle.setTitle("Paused", for: .normal)
        view.alpha = 1.0
        
        gameScene.loadAirplane(at: planePosition.level1, addToScene: true)
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
