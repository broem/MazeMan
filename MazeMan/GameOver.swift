//
//  GameOver.swift
//  MazeMan
//
//  Created by Ben on 4/10/17.
//  Copyright © 2017 Benjamin Leach. All rights reserved.
//

//import Foundation
import SpriteKit
import GameplayKit

class GameOver: SKScene {
    
    var scoreArray = [Int]()
    var score = Int()
    let death = SKAction.playSoundFileNamed("death.wav", waitForCompletion: false)
    let end = SKAudioNode(fileNamed: "ending.mp3")
//    init(size: CGSize, score: Int) {
//        super.init(size: size)
//        
//        let gameOverLabel = SKLabelNode(fontNamed: "VT323-Regular")
//        gameOverLabel.text = ("Game Over! Score: \(score)")
//        gameOverLabel.fontSize = 60
//        cScore = score
//        gameOverLabel.position = CGPoint(x: size.width/2, y: size.height/2)
//        self.addChild(gameOverLabel)
//        
//        
//    }

    override func didMove(to view: SKView) {
        // fill the array initially
        
        self.run(death)
//        self.run(end)
        end.autoplayLooped = true
        self.addChild(end)
        
        let gameOverLabel = SKLabelNode(fontNamed: "VT323-Regular")
        gameOverLabel.text = ("Game Over! Score: \(score)")
        gameOverLabel.fontSize = 60
//        cScore = score
        gameOverLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        self.addChild(gameOverLabel)

//        scoreArray.append(cScore)
        scoreArray = getSaved()
//        sortScores()
        setNewest()
//        let sizer = scoreArray.count
        sortScores()
        
        let scores = SKLabelNode(fontNamed: "VT323-Regular")
        scores.text = "High Scores: \(scoreArray[0]), \(scoreArray[1]), \(scoreArray[2])"
        scores.fontSize = 40
        scores.position = CGPoint(x: (size.width/2), y: (size.height/2)-40)
        addChild(scores)
    }
    
    func sortScores() {
        scoreArray = scoreArray.sorted { $0 > $1}
    }
    
    func setNewest(){
        scoreArray.append(score)
        
        UserDefaults.standard.set(scoreArray, forKey: "scoreArray")
        UserDefaults.standard.synchronize()
    }
    
    func getSaved() -> [Int]{
        if let data = UserDefaults.standard.array(forKey: "scoreArray") as? [Int] {
            return data
        } else {
            // if its not set do it!
            UserDefaults.standard.set([0,0,0], forKey: "scoreArray")
            UserDefaults.standard.synchronize()
            return [0,0,0]
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        _ = touch!.location(in: self)

        if let view = self.view {
            let scene = GameScene(size: view.bounds.size)
            let skView = view
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.ignoresSiblingOrder = true
            scene.scaleMode = .resizeFill
//            skView.showsPhysics = true
            skView.presentScene(scene)
        }
        
        
    }
   
}
