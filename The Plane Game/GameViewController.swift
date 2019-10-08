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
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var livesLabel: UILabel!
    @IBOutlet weak var playPauseButtonTitle: UIButton!
    @IBOutlet weak var centerStartButtonTitle: UIButton!
    
    var scoreDelegate: AdjustScoreDelegate!
    var gameScene: GameScene!
    var timer: Timer?
    
    var isGamePlaying = false
    let formatter = DateComponentsFormatter()
    let planeStartingPosition = CGPoint(x: 819, y: 181)
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var seconds = 30.0 {
        didSet {
            timerLabel.text = timeFormatter(time: seconds)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scoreDelegate = Score()
        
        centerStartButtonTitle.setTitle("Tap to Play", for: .normal)
        timerLabel.text = timeFormatter(time: seconds)
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
            gameScene.player.removeFromParent()
            gameScene.player.position = gameScene.playerLastKnownPosition
            gameScene.motionManager.stopAccelerometerUpdates()
            gameScene.isPaused = true
            isGamePlaying.toggle()
            timer?.invalidate()
        }
    }
    
    @IBAction func centerStartTapped(_ sender: UIButton) {
        beginGamePlay()
    }
    
    
    // MARK: - Updating Player Score & Lives
    func playerCollided(with node: SKNode) {
        if node.name == "runwayHitBox" {
            score += 100
            scoreDelegate.moveTo(level: 2)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.timer?.invalidate()
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
                    // Loop back to level 1 for testing purposes
                    self.scoreDelegate.moveTo(level: 1)
                    
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
                
                score = 0
                
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
                score = 0
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
            gameOver()

            // Reset lives and score labels.
            livesLabel.text = "Lives: \(Score.playerLives)"
        }
    }
    
    func scheduleTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] (timer) in
            self?.seconds -= 1.0
            
            if self?.seconds == 0 {
                self?.gameOver()
            }
        })
    }
    
    func beginGamePlay() {
        playPauseButtonTitle.setBackgroundImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
        playPauseButtonTitle.isHidden = false
        
        centerStartButtonTitle.isHidden = true
        centerStartButtonTitle.setTitle("Paused", for: .normal)
        view.alpha = 1.0
        
        gameScene.loadAirplane(at: planeStartingPosition, addToScene: true)
        gameScene.isPaused = false
        gameScene.motionManager.startAccelerometerUpdates()
        
        scheduleTimer()
        
        isGamePlaying.toggle()
    }
    
    func gameOver() {
        view.alpha = 0.5
        centerStartButtonTitle.setTitle("Game Over", for: .normal)
        centerStartButtonTitle.isHidden = false
        timer?.invalidate()
        gameScene.player.removeFromParent()
        
        
        seconds = 30.0
        Score.playerLives = 3
        Score.currentLevel = 1
        
        // show scores
        let ac = UIAlertController(title: "Game Over", message: "Your high score was: \(score)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true) {
            self.score = 0
        }
    }
    
    func timeFormatter(time: TimeInterval) -> String? {
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        
        guard let formattedTime = formatter.string(from: time) else {
            fatalError("No time found.")
        }
        return formattedTime
    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
