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
    var testGrid = [GridCell]()
    var counter = 0
   
    var bsize = 0
    var hsize = 0
    
//    let mano:           UInt32 = 1 << 1
//    let ground:         UInt32 = 1 << 2
//    let ceilingo:        UInt32 = 1 << 3
//    let water:          UInt32 = 1 << 4
//    let stega:          UInt32 = 1 << 5
//    let subflooro:       UInt32 = 1 << 6
    
    // rock spawning
    var rockTime = Timer()
    var rock = [SKSpriteNode]()
    
    // Stega
    var waterSpot = [CGPoint()]
    var stegaTime = Timer()
    var stegaDir = 70
    var dino = SKSpriteNode(imageNamed: "dino1")
    
    // tREX
    var rexSpot = [CGPoint()]
    var rexDir = 70
    var rex = SKSpriteNode(imageNamed: "dino2")
    
    var man = SKSpriteNode(imageNamed: "caveman")
    
    override func didMove(to view: SKView) {
//        print("\(mano)")
        bsize = Int(size.width/CGFloat(16))
        self.physicsWorld.contactDelegate = self
        
        let bgImg = SKSpriteNode(imageNamed: "bg")
//        bgImg.setScale(0.5)
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
                block.name = "waters"
            }
            if i == r2 {
                block = SKSpriteNode(imageNamed: "water")
                block.name = "waters"
            }
            
            block.size = CGSize(width: bsize, height: bsize)
//            block.setScale = 0.5
//            block.setScale(0.5)
            var posit = Int(block.frame.width) * i
            posit += bsize/2
            block.position = CGPoint(x: CGFloat(posit), y: block.frame.height/2)

            block.accessibilityLabel = "block\(i)"
            
            block.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bsize, height: bsize))
            block.physicsBody?.isDynamic = false
            block.physicsBody?.categoryBitMask = PhysicsCategory.ground.rawValue
//            block.physicsBody?.contactTestBitMask = PhysicsCategory.man.rawValue
//            block.physicsBody?.categoryBitMask = ground
//            block.physicsBody?.contactTestBitMask = mano
            
            if block.name == "waters" {
                block.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bsize, height: bsize))
                print("block pos: \(block.position)")
                waterSpot.append(block.position)
                block.physicsBody?.categoryBitMask = PhysicsCategory.water.rawValue
//                block.physicsBody?.contactTestBitMask = PhysicsCategory.man.rawValue
//                block.physicsBody?.categoryBitMask = water
//                block.physicsBody?.contactTestBitMask = mano
                block.physicsBody?.isDynamic = false
            }

            addChild(block)
        }
        // set top rows
        for i in 0...15{
            let block = SKSpriteNode(imageNamed: "block") // top row
            let block1 = SKSpriteNode(imageNamed: "block")
            
            block1.size = CGSize(width: bsize, height: bsize)
            block.size = CGSize(width: bsize, height: bsize)
            
            var posit = Int(block.frame.width) * i
            posit += bsize/2
            block.position = CGPoint(x: CGFloat(posit), y: (size.height-32))
            block1.position = CGPoint(x: CGFloat(posit), y: size.height-96)

            addChild(block)
            addChild(block1)
        }
        
        man.size = CGSize(width: bsize, height:bsize)
        man.position = CGPoint(x: size.width/2, y: size.height/2)
//        man.physicsBody?.categoryBitMask = mano
//        man.physicsBody?.contactTestBitMask = (ground | ceilingo | water)
        man.physicsBody?.collisionBitMask = 0
        
        
        
        addChild(man)
        
        baseTimer()
        
        addPhysics()
        addBounds()
        createGrid()
        rockSpawn()
        spawnStega()
        addBitMasks()
        
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
    
    func spawnStega() {
        let spot = (Int(arc4random_uniform(2))) + 1
        print("\(spot)")
        let loc = waterSpot[spot]
        print("\(loc)")
        dino.position = loc
        dino.size = CGSize(width: bsize, height: bsize)
        
        dino.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bsize-5, height: bsize-5))
        dino.physicsBody?.isDynamic = true
        dino.physicsBody?.affectedByGravity = false
        dino.physicsBody?.linearDamping = 0.0
        dino.physicsBody?.categoryBitMask = PhysicsCategory.stega.rawValue
//        dino.physicsBody?.contactTestBitMask = PhysicsCategory.man.rawValue
        dino.physicsBody?.contactTestBitMask = PhysicsCategory.ceiling.rawValue | PhysicsCategory.subfloor.rawValue
//        dino.physicsBody?.collisionBitMask = PhysicsCategory.ceiling.rawValue

        dino.physicsBody?.collisionBitMask = 0
        dino.physicsBody?.velocity = CGVector(dx: 0, dy: stegaDir)
        addChild(dino)
        
        
        
    }
    // the invisible grid
    func createGrid(){
//        counter = 0
        var xLoc = bsize/2
        var yLoc = bsize + Int(bsize/2)
        for _ in 0...8{
            for _ in 0...15{
                let point = CGPoint(x: xLoc, y: yLoc)
                let spot = GridCell(point, false, counter)
//                grid[i].append(spot)
                testGrid.append(spot)
                xLoc += bsize
                counter += 1
            }
            xLoc = bsize/2
            yLoc += bsize
//            counter += 1
        }
    }
    
    func addPhysics() {
        
        man.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bsize-5, height: bsize-5))
        man.physicsBody?.affectedByGravity =  false
        man.physicsBody?.linearDamping = 0.0
        man.physicsBody?.angularDamping = 0.0
        man.physicsBody?.allowsRotation = false
//        man.physicsBody?.velocity = CGVector(dx: stegaDir, dy: 0)
        
    }
    func addBitMasks() {
        
        man.physicsBody?.categoryBitMask = PhysicsCategory.man.rawValue
        man.physicsBody?.contactTestBitMask = PhysicsCategory.ground.rawValue | PhysicsCategory.ceiling.rawValue | PhysicsCategory.water.rawValue

//        man.physicsBody?.contactTestBitMask = ceilingo
//        man.physicsBody?.contactTestBitMask = water
    }
    
    func baseTimer() {
        
    }
    
    
    func rockSpawn() {
        var stop = 1
        rockTime = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){_ in
            if stop == 15 {
                self.theInvalidator()
            }
            let rand = Int(arc4random_uniform(UInt32(self.counter)))
            var rockToPlace = self.testGrid[rand]
            
            while rockToPlace.occupied == true {
                let rand = Int(arc4random_uniform(UInt32(self.counter)))
                rockToPlace = self.testGrid[rand]
            }
            
            rockToPlace.occupied = true
            let block = SKSpriteNode(imageNamed: "block")
            block.size = CGSize(width: self.bsize, height: self.bsize)
            block.position = rockToPlace.location
            block.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.bsize, height: self.bsize))
            block.physicsBody?.isDynamic = false
            block.physicsBody?.categoryBitMask = PhysicsCategory.ground.rawValue
//            block.physicsBody?.contactTestBitMask = PhysicsCategory.man.rawValue
//            block.physicsBody?.categoryBitMask = self.ground
//            block.physicsBody?.contactTestBitMask = self.mano
            
            self.addChild(block)
            
            
            stop += 1
        }
    }
    
    func theInvalidator(){
        rockTime.invalidate()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        

        
        print("YEP!")
        
        
        if (contact.bodyA.categoryBitMask == PhysicsCategory.man.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.ground.rawValue) {
            print("CONTACT HERE")
            man.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
        } else if (contact.bodyB.categoryBitMask == PhysicsCategory.man.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.ground.rawValue) {
            print("CONTACT HERE")
            man.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
        }
        
        if (contact.bodyA.categoryBitMask == PhysicsCategory.man.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.ceiling.rawValue) {
            print("CONTACT HERE")
            man.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
        } else if (contact.bodyB.categoryBitMask == PhysicsCategory.man.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.ceiling.rawValue) {
            print("CONTACT HERE")
            man.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
        }
        
        if (contact.bodyA.categoryBitMask == PhysicsCategory.stega.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.ceiling.rawValue) {
            print("dino HERE")
            dino.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
            let rand = Int(arc4random_uniform(4))
            let delay = DispatchTime.now() + Double(rand)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.stegaDir = self.stegaDir * -1
                self.dino.physicsBody?.velocity = CGVector(dx: 0, dy: self.stegaDir)}
        } else if (contact.bodyB.categoryBitMask == PhysicsCategory.stega.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.ceiling.rawValue) {
            print("dino HERE")
            dino.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
            let rand = Int(arc4random_uniform(4))
            let delay = DispatchTime.now() + Double(rand)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.stegaDir = self.stegaDir * -1
                self.dino.physicsBody?.velocity = CGVector(dx: 0, dy: self.stegaDir)}
        }
        
        if (contact.bodyA.categoryBitMask == PhysicsCategory.stega.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.subfloor.rawValue) {
            print("dino HERE low")
            dino.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
            let rand = Int(arc4random_uniform(4))
            let delay = DispatchTime.now() + Double(rand)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.stegaDir = self.stegaDir * -1
                self.dino.physicsBody?.velocity = CGVector(dx: 0, dy: self.stegaDir)}
        } else if (contact.bodyB.categoryBitMask == PhysicsCategory.stega.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.subfloor.rawValue) {
            print("dino HERE")
            dino.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
            let rand = Int(arc4random_uniform(4))
            let delay = DispatchTime.now() + Double(rand)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.stegaDir = self.stegaDir * -1
                self.dino.physicsBody?.velocity = CGVector(dx: 0, dy: self.stegaDir)}
        }


//        else if contact.bodyB.categoryBitMask == PhysicsCategory.man.rawValue || contact.bodyA.categoryBitMask == PhysicsCategory.ground.rawValue || contact.bodyB.categoryBitMask == PhysicsCategory.ceiling.rawValue {
//             print("CONTACT HERE")
//            man.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
//        }
//        
//        else if contact.bodyA.categoryBitMask == PhysicsCategory.man.rawValue || contact.bodyB.categoryBitMask == PhysicsCategory.water.rawValue {
//            print("water!")
//            man.removeFromParent()
//        }
//        
//        else if contact.bodyB.categoryBitMask == PhysicsCategory.man.rawValue || contact.bodyA.categoryBitMask == PhysicsCategory.water.rawValue {
//            print("water")
//            man.removeFromParent()
//        }
//        
//        else if contact.bodyA.categoryBitMask == PhysicsCategory.stega.rawValue || contact.bodyB.categoryBitMask == PhysicsCategory.ceiling.rawValue {
//            // wait then move
//            print("STEGA!")
////            contact.bodyA.velocity = CGVector(dx: 0, dy: 0)
////            let rand = Int(arc4random_uniform(4))
////            let delay = DispatchTime.now() + Double(rand)
////            DispatchQueue.main.asyncAfter(deadline: delay) {
////                
////                self.dino.physicsBody?.velocity = CGVector(dx: 0, dy: self.stegaDir/(-1))
////            }
//
//        }
//        
//        else if contact.bodyB.categoryBitMask == PhysicsCategory.stega.rawValue || contact.bodyA.categoryBitMask == PhysicsCategory.ceiling.rawValue{
//            // wait then move
//            print("STEGA!")
////            contact.bodyB.velocity = CGVector(dx: 0, dy: 0)
////            let rand = Int(arc4random_uniform(4))
////            let delay = DispatchTime.now() + Double(rand)
////            DispatchQueue.main.asyncAfter(deadline: delay) {
////        
////                self.dino.physicsBody?.velocity = CGVector(dx: 0, dy: self.stegaDir/(-1))
////            }
//        }
        
        
}

    func leftSwipe(){ man.physicsBody?.velocity = (CGVector(dx: -100, dy: 0)) }
    
    func rightSwipe(){ man.physicsBody?.velocity = (CGVector(dx: 100, dy: 0)) }
    
    func upSwipe(){ man.physicsBody?.velocity = (CGVector(dx: 0, dy: 100)) }
    
    func downSwipe(){man.physicsBody?.velocity = (CGVector(dx: 0, dy: -100)) }
    
    
    func addBounds(){
        let subfloor = SKNode()
        subfloor.position = CGPoint(x: 0, y: -1)
        subfloor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 2*self.frame.width, height: 1))
        subfloor.physicsBody?.isDynamic = false
        subfloor.physicsBody?.categoryBitMask = PhysicsCategory.subfloor.rawValue
//        subfloor.physicsBody?.contactTestBitMask = PhysicsCategory.stega.rawValue
//        subfloor.physicsBody?.categoryBitMask = subflooro
//        subfloor.physicsBody?.contactTestBitMask = mano
        addChild(subfloor)
        
        let ceiling = SKNode()
        ceiling.position = CGPoint(x: 0, y: size.height-128)
        ceiling.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 2*self.frame.width, height: 1))
        ceiling.physicsBody?.isDynamic = false
        ceiling.physicsBody?.categoryBitMask = PhysicsCategory.ceiling.rawValue
//        ceiling.physicsBody?.contactTestBitMask = PhysicsCategory.man.rawValue
//        ceiling.physicsBody?.contactTestBitMask = PhysicsCategory.stega.rawValue
//        ceiling.physicsBody?.categoryBitMask = ceilingo
//        ceiling.physicsBody?.contactTestBitMask = mano
        addChild(ceiling)
        
        let wallLeft = SKNode()
        wallLeft.position = CGPoint(x: size.width, y: 0)
        wallLeft.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: 2*self.frame.height))
        wallLeft.physicsBody?.isDynamic = false
        wallLeft.physicsBody?.categoryBitMask = PhysicsCategory.ground.rawValue
//        wallLeft.physicsBody?.contactTestBitMask = PhysicsCategory.man.rawValue
//        wallLeft.physicsBody?.categoryBitMask = ground
//        wallLeft.physicsBody?.contactTestBitMask = mano
        addChild(wallLeft)
        
        let wallRight = SKNode()
        wallRight.position = CGPoint(x: 0, y: 0)
        wallRight.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: 2*self.frame.height))
        wallRight.physicsBody?.isDynamic = false
        wallRight.physicsBody?.categoryBitMask = PhysicsCategory.ground.rawValue
//        wallRight.physicsBody?.contactTestBitMask = PhysicsCategory.man.rawValue
//        wallRight.physicsBody?.categoryBitMask = ground
//        wallRight.physicsBody?.contactTestBitMask = mano
        addChild(wallRight)
    }

    
    enum PhysicsCategory : UInt32 {
        case man = 1
        case wallLeft = 2
        case wallRight = 4
        case ground = 8
        case ceiling = 16
        case water = 32
        case stega = 64
        case subfloor = 128
    }
}
