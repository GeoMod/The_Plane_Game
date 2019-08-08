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
    
    var gameScene = GameScene()
    
    var isGamePlaying = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "LevelOne") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
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
            playPauseButtonTitle.setBackgroundImage(UIImage(systemName: "play.circle.fill"), for: .normal)
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
        playPauseButtonTitle.setBackgroundImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
        playPauseButtonTitle.isHidden = false
        
        centerStartButtonTitle.isHidden = true
        centerStartButtonTitle.setTitle("Paused", for: .normal)
        view.alpha = 1.0
        
        // From old code.
        // But still need a means of loading the airplane back into the scene after pausing the game, or at scene/level transition.
//        gameScene.loadAirplane(at: gameScene.playerLastKnownPosition, addToScene: true)
        
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
