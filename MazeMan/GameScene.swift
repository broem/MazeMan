//
//  GameScene.swift
//  MazeMan
//
//  Created by Ben on 4/4/17.
//  Copyright © 2017 Benjamin Leach. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
//    var entities = [GKEntity]()
//    var graphs = [String : GKGraph]()
    
    var grid = [[GridCell]]()
    
    var man = SKSpriteNode(imageNamed: "caveman")
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        let bgImg = SKSpriteNode(imageNamed: "bg")
        bgImg.size = CGSize(width: size.width*2, height:size.height*2)
        addChild(bgImg)
        
        // gen 2 rand nums
        // while equal, make sure not equal
        let r1 = Int(arc4random_uniform(15))
        var r2 = Int(arc4random_uniform(15))
        print("\(r1) and \(r2)")
        while r1 == r2 {
            r2 = Int(arc4random_uniform(15))
        }
        
        // set bottom row
        for i in 0...15{
            
            var block = SKSpriteNode(imageNamed: "block")
            
            if i == r1 {
                block = SKSpriteNode(imageNamed: "water")
                block.name = "water"
            }
            if i == r2 {
                block = SKSpriteNode(imageNamed: "water")
                block.name = "water"
            }
            
           
            
            block.size = CGSize(width: 85, height: 85)
            var posit = Int(block.frame.width) * i
            posit += 45
            block.position = CGPoint(x: CGFloat(posit), y: block.frame.height/2)

            block.accessibilityLabel = "block\(i)"
            
            block.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 85, height: 85))
            block.physicsBody?.isDynamic = false
            block.physicsBody?.categoryBitMask = PhysicsCategory.ground.rawValue
            block.physicsBody?.contactTestBitMask = PhysicsCategory.man.rawValue
            
            if block.name == "water" {
                block.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 85, height: 83))
                block.physicsBody?.categoryBitMask = PhysicsCategory.water.rawValue
                block.physicsBody?.contactTestBitMask = PhysicsCategory.man.rawValue
//                block.physicsBody?.isDynamic = true
            }

            addChild(block)
        }
        // set top rows
        for i in 0...15{
            let block = SKSpriteNode(imageNamed: "block") // top row
            let block1 = SKSpriteNode(imageNamed: "block")
            
            block1.size = CGSize(width: 85, height: 85)
            block.size = CGSize(width: 85, height: 85)
            
            var posit = Int(block.frame.width) * i
            posit += 45
            block.position = CGPoint(x: CGFloat(posit), y: size.height-43)
            block1.position = CGPoint(x: CGFloat(posit), y: size.height-128)

            addChild(block)
            addChild(block1)
        }
        
        man.size = CGSize(width: 85, height: 85)
        man.position = CGPoint(x: size.width/2, y: size.height/2)
        
        
        
        addChild(man)
        
        
        addBitMasks()
        addPhysics()
        addBounds()
        
        let swipeRight = UISwipeGestureRecognizer()
        swipeRight.addTarget(self, action: #selector(rightSwipe))
        swipeRight.direction = .right
        self.view?.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer()
        swipeLeft.addTarget(self, action: #selector(leftSwipe))
        swipeLeft.direction = .left
        self.view?.addGestureRecognizer(swipeLeft)
        
        let swipeUp = UISwipeGestureRecognizer()
        swipeUp.addTarget(self, action: #selector(upSwipe))
        swipeUp.direction = .up
        self.view?.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer()
        swipeDown.addTarget(self, action: #selector(downSwipe))
        swipeDown.direction = .down
        self.view?.addGestureRecognizer(swipeDown)
        
    }
    
    func createGrid(){
        for i in 0...15{
            
        }
    }
    
    func addPhysics(){
        
        man.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: man.frame.width-1, height: man.frame.height-1))
        man.physicsBody?.affectedByGravity =  false
        man.physicsBody?.linearDamping = 0.0
 
        
        
    }
    func addBitMasks(){
        
        man.physicsBody?.categoryBitMask = PhysicsCategory.man.rawValue
        man.physicsBody?.contactTestBitMask = PhysicsCategory.ground.rawValue
        man.physicsBody?.contactTestBitMask = PhysicsCategory.ceiling.rawValue
        man.physicsBody?.contactTestBitMask = PhysicsCategory.wallLeft.rawValue
        man.physicsBody?.contactTestBitMask = PhysicsCategory.wallRight.rawValue
        man.physicsBody?.contactTestBitMask = PhysicsCategory.water.rawValue
        
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == PhysicsCategory.man.rawValue || contact.bodyB.categoryBitMask == PhysicsCategory.ground.rawValue || contact.bodyB.categoryBitMask == PhysicsCategory.wallRight.rawValue || contact.bodyB.categoryBitMask == PhysicsCategory.wallLeft.rawValue  || contact.bodyB.categoryBitMask == PhysicsCategory.ceiling.rawValue{
            print("CONTACT HERE")
            man.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
            
        }
        else if contact.bodyB.categoryBitMask == PhysicsCategory.man.rawValue || contact.bodyA.categoryBitMask == PhysicsCategory.ground.rawValue || contact.bodyA.categoryBitMask == PhysicsCategory.wallRight.rawValue || contact.bodyA.categoryBitMask == PhysicsCategory.wallLeft.rawValue  || contact.bodyA.categoryBitMask == PhysicsCategory.ceiling.rawValue{
             print("CONTACT HERE")
            man.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
        }
        
        else if contact.bodyA.categoryBitMask == PhysicsCategory.man.rawValue || contact.bodyB.categoryBitMask == PhysicsCategory.water.rawValue {
            print("water!")
            man.removeFromParent()
        }
        
        else if contact.bodyB.categoryBitMask == PhysicsCategory.man.rawValue || contact.bodyA.categoryBitMask == PhysicsCategory.water.rawValue {
            print("water")
            man.removeFromParent()
        }
        
        
    }
    
    func leftSwipe(){ man.physicsBody?.velocity = (CGVector(dx: -100, dy: 0)) }
    
    func rightSwipe(){ man.physicsBody?.velocity = (CGVector(dx: 100, dy: 0)) }
    
    func upSwipe(){ man.physicsBody?.velocity = (CGVector(dx: 0, dy: 100)) }
    
    func downSwipe(){man.physicsBody?.velocity = (CGVector(dx: 0, dy: -100)) }
    
    
    func addBounds(){
//        let ground = SKNode()
//        ground.position = CGPoint(x: 0, y: 85)
//        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 2*self.frame.width, height: 1))
//        ground.physicsBody?.isDynamic = false
//        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground.rawValue
//        ground.physicsBody?.contactTestBitMask = PhysicsCategory.man.rawValue
//        addChild(ground)
        
        let ceiling = SKNode()
        ceiling.position = CGPoint(x: 0, y: size.height-170)
        ceiling.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 2*self.frame.width, height: 1))
        ceiling.physicsBody?.isDynamic = false
        ceiling.physicsBody?.categoryBitMask = PhysicsCategory.ceiling.rawValue
        ceiling.physicsBody?.contactTestBitMask = PhysicsCategory.man.rawValue
        addChild(ceiling)
        
        let wallLeft = SKNode()
        wallLeft.position = CGPoint(x: size.width, y: 0)
        wallLeft.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: 2*self.frame.height))
        wallLeft.physicsBody?.isDynamic = false
        wallLeft.physicsBody?.categoryBitMask = PhysicsCategory.wallLeft.rawValue
        wallLeft.physicsBody?.contactTestBitMask = PhysicsCategory.man.rawValue
        addChild(wallLeft)
        
        let wallRight = SKNode()
        wallRight.position = CGPoint(x: 0, y: 0)
        wallRight.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: 2*self.frame.height))
        wallRight.physicsBody?.isDynamic = false
        wallRight.physicsBody?.categoryBitMask = PhysicsCategory.wallRight.rawValue
        wallRight.physicsBody?.contactTestBitMask = PhysicsCategory.man.rawValue
        addChild(wallRight)
    }

    
    enum PhysicsCategory : UInt32 {
        case man = 1
        case wallLeft = 2
        case wallRight = 4
        case ground = 8
        case ceiling = 16
        case water = 32
    }
}
