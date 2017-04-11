//
//  GameOver.swift
//  MazeMan
//
//  Created by Ben on 4/10/17.
//  Copyright © 2017 Benjamin Leach. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class GameOver: SKScene {
    
    var scoreArray = [Int]()
    
    init(size: CGSize, score: Int) {
        super.init(size: size)
        
        let gameOverLabel = SKLabelNode(fontNamed: "VT323-Regular")
        gameOverLabel.text = ("Game Over! Score: \(score)")
        gameOverLabel.fontSize = 60
        
        gameOverLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        self.addChild(gameOverLabel)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        if scoreArray.isEmpty {
            for _ in 1...4 {
                scoreArray.append(0)
            }
        }
        
        
        let scores = SKLabelNode(fontNamed: "VT323-Regular")
        scores.text = "High Scores: \(scoreArray[1]), \(scoreArray[2]), \(scoreArray[3])"
        scores.fontSize = 40
        scores.position = CGPoint(x: (size.width/2), y: (size.height/2)-40)
        addChild(scores)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        _ = touch!.location(in: self)

        if let view = self.view {
            let scene = GameScene(size: view.bounds.size)
            let skView = view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.ignoresSiblingOrder = true
            scene.scaleMode = .resizeFill
            skView.showsPhysics = true
            skView.presentScene(scene)
        }
        
        
    }
}
