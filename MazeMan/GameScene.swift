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
    
    let intro = SKAction.playSoundFileNamed("Pacman.wav", waitForCompletion: true)
    let playTime = SKAction.playSoundFileNamed("dinoTime.mp3", waitForCompletion: true)
    
    
    var testGrid = [GridCell]()
    var counter = 0
   
    var bsize = 0
    var hsize = 0
    
    var curscore = 0
    
    // glob
    var dmgTime = Timer()
    
    // top stuff
    var statusPan = SKSpriteNode(imageNamed: "game-status-panel")
    var label = SKLabelNode()
    
    // bottom stuff
    var botStar = SKLabelNode()
    var stars = Int()
    var botRock = SKLabelNode()
    var rocks = Int()
    var botHeart = SKLabelNode()
    var hearts = Int()
    var botBat = SKLabelNode()
    var battery = Int()
    var life = Int()
    
    //gravity
    var gravityTimer = Timer()
    var gravityWarning = Timer()
    
    // rock spawning
    var rockTime = Timer()
    var rock = [SKSpriteNode]()
    
    // Stega
    var waterSpot = [CGPoint()]
    var stegaTime = Timer()
    var stegaDir = 70
    var dino = SKSpriteNode(imageNamed: "dino1")
    
    // tREX
    var rexSpot = [Int()]
    var rexDir = -70
    var rex = SKSpriteNode(imageNamed: "dino2")
    
    // redDino
    var redDir = 70
    var redCurrentDir = 2
    var red = SKSpriteNode(imageNamed: "dino3")
    
    //fly
    var flyDir = 70
    var fly = SKSpriteNode(imageNamed: "dino4")
    var fireBallTimer = Timer()
    
    // star
    var star = SKSpriteNode(imageNamed: "star")
    var starLoc = 0
    
    // food
    var food = SKSpriteNode(imageNamed: "food")
    var foodLoc = 0
    
    var man = SKSpriteNode(imageNamed: "caveman")
    
    override func didMove(to view: SKView) {
//        print("\(mano)")
        let runner = SKAction.repeatForever(playTime)
        
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
        
        gravityTime()
        statusPanel()
        updatePanel("Welcome CAVEMAN")
        bottomStuff()
        initializeScores()
        globalTimer()
        addPhysics()
        addBounds()
        createGrid()
        rockSpawn()
        spawnStega()
        spawnRex()
        spawnRed()
        spawnFly()
        spawnStar()
        spawnFood()
        addBitMasks()
        updateScore()
        
        self.run(intro)
        self.run(runner)
        
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
    
    func spawnStar() {
//        var ok = testGrid.count
//        print("size of grid =  \(ok)")
        // choose a random spot in all the grid array, is not occupied, set down
        var rand = Int(arc4random_uniform(143)) + 1
        var starPlace = testGrid[rand]
        while starPlace.occupied == true && (starPlace.location == red.position) && (starPlace.location == dino.position) && (starPlace.location == rex.position) {
            // block loc
            print("dupe rand: \(rand)")
            rand = Int(arc4random_uniform(143)) + 1
            starPlace = testGrid[rand]
        }
        starLoc = rand
        starPlace.occupied = true
//        print("star here at : \(testGrid[rand].location)")
        star.position = starPlace.location
        
        if starPlace.location
        
        star.size = CGSize(width: bsize, height: bsize)
        star.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bsize, height: bsize))
        star.physicsBody?.isDynamic = true
        star.physicsBody?.categoryBitMask = PhysicsCategory.star.rawValue
        star.physicsBody?.collisionBitMask = 0
        star.physicsBody?.affectedByGravity = false
        star.physicsBody?.contactTestBitMask = PhysicsCategory.man.rawValue
        addChild(star)
        
    }
    
    func spawnFood() {
        // choose a random spot in all the grid array, is not occupied, set down
        var rand = Int(arc4random_uniform(143)) + 1
        while testGrid[rand].occupied == true && (testGrid[rand].location == red.position) && (testGrid[rand].location == dino.position) && (testGrid[rand].location == rex.position) && (testGrid[rand].location == star.position) && (testGrid[rand].location == man.position) {
            // block loc
            print("fooddupe rand: \(rand)")
            rand = Int(arc4random_uniform(143)) + 1
        }
        foodLoc = rand
        testGrid[rand].occupied = true
        
        food.position = testGrid[rand].location
        food.size = CGSize(width: bsize, height: bsize)
        food.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bsize, height: bsize))
        food.physicsBody?.isDynamic = true
        food.physicsBody?.categoryBitMask = PhysicsCategory.food.rawValue
        food.physicsBody?.collisionBitMask = 0
        food.physicsBody?.affectedByGravity = false
        food.physicsBody?.contactTestBitMask = PhysicsCategory.man.rawValue | PhysicsCategory.stega.rawValue | PhysicsCategory.rex.rawValue | PhysicsCategory.red.rawValue
        addChild(food)
        
    }
    
    func fireZeBalls() {
        fireBallTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true){_ in
            let rand = Int(arc4random_uniform(6)) + 1
            let delay = DispatchTime.now() + Double(rand)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                let fireBall = SKSpriteNode(imageNamed: "fire")
                fireBall.position = self.fly.position
                fireBall.size = CGSize(width: self.bsize, height: self.bsize)
                fireBall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.bsize, height: self.bsize))
                fireBall.physicsBody?.isDynamic = true
                fireBall.physicsBody?.linearDamping = 0.0
                fireBall.physicsBody?.affectedByGravity = false
                fireBall.physicsBody?.categoryBitMask = PhysicsCategory.fireBall.rawValue
                fireBall.physicsBody?.collisionBitMask = 0
                fireBall.physicsBody?.friction = 0.0
                fireBall.physicsBody?.velocity = CGVector(dx: 0, dy: -70)
                fireBall.physicsBody?.contactTestBitMask = PhysicsCategory.subfloor.rawValue | PhysicsCategory.rock.rawValue | PhysicsCategory.man.rawValue
                self.addChild(fireBall)
            }
        }
        fireBallTimer.fire()
    }
    
    func spawnFly() {
        let ytop = Int(size.height) - ((bsize*2)-(bsize/2))
        fly.position = CGPoint(x: bsize, y: ytop)
        fly.size = CGSize(width: bsize, height: bsize)
        fly.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bsize, height: bsize))
        fly.physicsBody?.isDynamic = true
        fly.physicsBody?.affectedByGravity = false
        fly.physicsBody?.linearDamping = 0.0
        fly.physicsBody?.categoryBitMask = PhysicsCategory.fly.rawValue
        
        fly.physicsBody?.contactTestBitMask = PhysicsCategory.ground.rawValue
        fly.physicsBody?.collisionBitMask = 0
        fly.physicsBody?.velocity = CGVector(dx: 70, dy: 0)
        addChild(fly)
        fireZeBalls()
        
        
    }
    
    func spawnRed() {
        // starts at top left
//        let ytop = Int(size.height) - ((bsize*3)-(bsize/2)) - 2
        // check if location is available
        var locNum = 128
        while testGrid[locNum].occupied == true {
            locNum += 1
        }
        
        let testm = testGrid[locNum].location
        
        red.position = testm
//        red.position = CGPoint(x: bsize, y: ytop)
        red.size = CGSize(width: bsize, height: bsize)
        red.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bsize, height: bsize))
        red.physicsBody?.isDynamic = true
        red.physicsBody?.affectedByGravity = false
        red.physicsBody?.linearDamping = 0.0
        red.physicsBody?.categoryBitMask = PhysicsCategory.red.rawValue
        //        dino.physicsBody?.contactTestBitMask = PhysicsCategory.man.rawValue
        red.physicsBody?.contactTestBitMask = PhysicsCategory.ground.rawValue | PhysicsCategory.blocks.rawValue | PhysicsCategory.ceiling.rawValue | PhysicsCategory.rock.rawValue | PhysicsCategory.man.rawValue  //        dino.physicsBody?.collisionBitMask = PhysicsCategory.ceiling.rawValue
        
        red.physicsBody?.collisionBitMask = 0
//        red.physicsBody?.velocity = CGVector(dx: redDir, dy: 0)
        addChild(red)

    }
    
    func spawnRex(){
        let spot = (Int(arc4random_uniform(8))) + 1
        let yloc = rexSpot[spot]
        
        rex.position = CGPoint(x: Int(size.width)-(bsize/2),y: yloc)
        rex.size = CGSize(width: bsize, height: bsize)
        rex.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bsize-5, height: bsize-5))
        rex.physicsBody?.isDynamic = true
        rex.physicsBody?.affectedByGravity = false
        rex.physicsBody?.linearDamping = 0.0
        rex.physicsBody?.categoryBitMask = PhysicsCategory.rex.rawValue
        //        dino.physicsBody?.contactTestBitMask = PhysicsCategory.man.rawValue
        rex.physicsBody?.contactTestBitMask = PhysicsCategory.ground.rawValue | PhysicsCategory.man.rawValue       //        dino.physicsBody?.collisionBitMask = PhysicsCategory.ceiling.rawValue
        
        rex.physicsBody?.collisionBitMask = 0
        rex.physicsBody?.velocity = CGVector(dx: rexDir, dy: 0)
        addChild(rex)
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
        dino.physicsBody?.contactTestBitMask = PhysicsCategory.ceiling.rawValue | PhysicsCategory.subfloor.rawValue | PhysicsCategory.man.rawValue
//        dino.physicsBody?.collisionBitMask = PhysicsCategory.ceiling.rawValue
        dino.physicsBody?.angularDamping = 0.0
        dino.physicsBody?.allowsRotation = false
        dino.physicsBody?.collisionBitMask = 0
        dino.physicsBody?.velocity = CGVector(dx: 0, dy: stegaDir)
        addChild(dino)
    }
    
    func statusPanel() {
        let scale = (bsize * 2) - 20
        let topSide = Int(size.height) - bsize
        statusPan.position = CGPoint(x: Int(size.width/2), y: topSide)
        statusPan.size = CGSize(width: 1000, height: scale)
        addChild(statusPan)
        label.fontSize = 55
        label.fontName = "VT323-Regular"
//        label.text = "Ok test"
        label.position = CGPoint(x: Int(size.width/2), y: topSide-15)
        addChild(label)
    }
    
    func updatePanel(_ tex: String) {
        label.text = "\(tex)"
    }
    
    // the invisible grid
    func createGrid(){
//        counter = 0
        var xLoc = bsize/2
        var yLoc = bsize + Int(bsize/2)
        for _ in 0...8{
            rexSpot.append(yLoc)
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
//        man.physicsBody?.collisionBitMask = PhysicsCategory.ground.rawValue
//        man.physicsBody?.velocity = CGVector(dx: stegaDir, dy: 0)
        
    }
    func addBitMasks() {
        
        man.physicsBody?.categoryBitMask = PhysicsCategory.man.rawValue
        man.physicsBody?.contactTestBitMask = PhysicsCategory.ground.rawValue | PhysicsCategory.ceiling.rawValue | PhysicsCategory.water.rawValue | PhysicsCategory.blocks.rawValue
        man.physicsBody?.collisionBitMask = PhysicsCategory.ground.rawValue | PhysicsCategory.blocks.rawValue

//        man.physicsBody?.contactTestBitMask = ceilingo
//        man.physicsBody?.contactTestBitMask = water
    }
    
    func gravityTime() {
        let rand = Int(arc4random_uniform(60))+40
        
        gravityWarning = Timer.scheduledTimer(withTimeInterval: TimeInterval(rand-3), repeats: false){_ in
            self.label.text = "GRAVITY TIME IS COMING!!"
        }
        
        gravityTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(rand), repeats: false){_ in
            self.gravityOff()
        }
        
    }
    func gravityOff() {
        man.physicsBody?.affectedByGravity = true
        
        let delay = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: delay) {
            self.man.physicsBody?.affectedByGravity = false}
        label.text = "Good luck, Caveman!"
        gravityTime()
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
            block.physicsBody?.categoryBitMask = PhysicsCategory.blocks.rawValue
//            block.physicsBody?.contactTestBitMask = PhysicsCategory.man.rawValue
//            block.physicsBody?.categoryBitMask = self.ground
//            block.physicsBody?.contactTestBitMask = self.mano
            
            self.addChild(block)
            
            
            stop += 1
        }
    }
    
    func bottomStuff() {
        let starBot = SKSpriteNode(imageNamed: "star")
        let rockBot = SKSpriteNode(imageNamed: "rock")
        let heartBot = SKSpriteNode(imageNamed: "heart")
        let batteryBot = SKSpriteNode(imageNamed: "battery")
        
        starBot.position = CGPoint(x: bsize/2, y: bsize/2)
        starBot.size = CGSize(width: bsize, height: bsize)
        botStar.fontSize = 30
        botStar.fontName = "VT323-Regular"
        botStar.position = CGPoint(x: bsize/2, y: (bsize/2)-10)
        addChild(starBot)
        
        rockBot.position = CGPoint(x: (bsize/2)+bsize, y: (bsize/2))
        rockBot.size = CGSize(width: bsize, height: bsize)
        botRock.fontSize = 30
        botRock.fontName = "VT323-Regular"
        botRock.position = CGPoint(x: (bsize/2)+bsize, y: (bsize/2)-10)
        addChild(rockBot)
        
        heartBot.position = CGPoint(x: (bsize/2)+(bsize*2), y: bsize/2)
        heartBot.size = CGSize(width: bsize, height: bsize)
        botHeart.fontSize = 30
        botHeart.fontName = "VT323-Regular"
        botHeart.position = CGPoint(x: (bsize/2)+(bsize*2), y: (bsize/2)-10)
        addChild(heartBot)
        
        batteryBot.position = CGPoint(x: (bsize/2)+(bsize*3)+20, y: bsize/2)
        batteryBot.size = CGSize(width: bsize+60, height: bsize*2)
        botBat.fontSize = 40
        botBat.fontName = "VT323-Regular"
        botBat.position = CGPoint(x: (bsize/2)+(bsize*3)+20, y: (bsize/2)-10)
        addChild(batteryBot)
       
    }
    
    func initializeScores() {
        addChild(botStar)
        addChild(botRock)
        addChild(botHeart)
        addChild(botBat)
        stars = 0
        rocks = 10
        life = 300
//        hearts = Int(round(Double(life/100)))+1
//        battery = Int(round(Double((life/300)*100)))
//        print("\(battery)")
        
    }
    
    func globalTimer() {
        dmgTime = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){_ in
            self.life -= 1
            self.updateScore()
            self.checkLife()
        }
        dmgTime.fire()
    }
    
    func checkLife() {
        if life <= 0 {
            GameOverMan()
        }
    }
    
    func updateScore() {
        hearts = Int(round(Double(life/100)))+1
        battery = Int(round((Double(life)/300)*100))
        botStar.text = "\(stars)"
        botRock.text = "\(rocks)"
        botHeart.text = "\(hearts)"
        botBat.text = "\(battery)"
        print("life: \(life)")
        print("heart: \(hearts)")
        print("Bat: \(battery)")
    }
    
    func theInvalidator(){
        rockTime.invalidate()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // CaveMan
        if (contact.bodyA.categoryBitMask == PhysicsCategory.man.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.ground.rawValue) {
//            print("CONTACT HERE")
            man.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
        } else if (contact.bodyB.categoryBitMask == PhysicsCategory.man.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.ground.rawValue) {
//            print("CONTACT HERE")
            man.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
        }
        
        if (contact.bodyA.categoryBitMask == PhysicsCategory.man.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.ceiling.rawValue) {
//            print("CONTACT HERE")
            man.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
        } else if (contact.bodyB.categoryBitMask == PhysicsCategory.man.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.ceiling.rawValue) {
//            print("CONTACT HERE")
            man.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
        }
        
        if (contact.bodyA.categoryBitMask == PhysicsCategory.man.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.blocks.rawValue) {
//            print("CONTACT HERE")
            man.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
        } else if (contact.bodyB.categoryBitMask == PhysicsCategory.man.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.blocks.rawValue) {
//            print("CONTACT HERE")
            man.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
        }
        
        // water
        if (contact.bodyA.categoryBitMask == PhysicsCategory.man.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.water.rawValue) {
            //            print("CONTACT HERE")
            man.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
            GameOverMan()
        } else if (contact.bodyB.categoryBitMask == PhysicsCategory.man.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.water.rawValue) {
            //            print("CONTACT HERE")
            man.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
            GameOverMan()
        }
        
        
        
        
        // STEGA
        if (contact.bodyA.categoryBitMask == PhysicsCategory.stega.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.ceiling.rawValue) {
            print("dino HERE")
//            dino.position.y = dino.position.y-10
            dino.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
            let rand = Int(arc4random_uniform(4))
            let delay = DispatchTime.now() + Double(rand)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.stegaDir = self.stegaDir * -1
                self.dino.physicsBody?.velocity = CGVector(dx: 0, dy: self.stegaDir)}
        } else if (contact.bodyB.categoryBitMask == PhysicsCategory.stega.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.ceiling.rawValue) {
            print("dino HERE")
//            dino.position.y = dino.position.y-10
            dino.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
            let rand = Int(arc4random_uniform(4))+1
            let delay = DispatchTime.now() + Double(rand)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.stegaDir = self.stegaDir * -1
                self.dino.physicsBody?.velocity = CGVector(dx: 0, dy: self.stegaDir)}
        }
        
        if (contact.bodyA.categoryBitMask == PhysicsCategory.stega.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.subfloor.rawValue) {
            print("dino HERE low")
            dino.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
            let rand = Int(arc4random_uniform(4))+1
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
        
        if (contact.bodyA.categoryBitMask == PhysicsCategory.stega.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.man.rawValue) {
            //            print("rex HERE")
            removeLife(60)
            
        } else if (contact.bodyB.categoryBitMask == PhysicsCategory.stega.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.man.rawValue) {
            //            print("rex HERE")
            removeLife(60)
        }
        
        //REX
        if (contact.bodyA.categoryBitMask == PhysicsCategory.rex.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.ground.rawValue) {
            print("rex HERE")
            rex.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
            let rand = Int(arc4random_uniform(4))
            let delay = DispatchTime.now() + Double(rand)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.rexDir = self.rexDir * -1
                self.rex.xScale = self.rex.xScale * -1.0
                self.rex.physicsBody?.velocity = CGVector(dx: self.rexDir, dy: 0)}
        } else if (contact.bodyB.categoryBitMask == PhysicsCategory.rex.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.ground.rawValue) {
            print("rex HERE")
            rex.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
            let rand = Int(arc4random_uniform(4))
            let delay = DispatchTime.now() + Double(rand)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.rexDir = self.rexDir * -1
                self.rex.xScale = self.rex.xScale * -1.0
                self.rex.physicsBody?.velocity = CGVector(dx: self.rexDir, dy: 0)}
        }
        
        if (contact.bodyA.categoryBitMask == PhysicsCategory.rex.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.man.rawValue) {
            removeLife(80)
            
        } else if (contact.bodyB.categoryBitMask == PhysicsCategory.rex.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.man.rawValue) {
            removeLife(80)
        }
        
        
        //RedDino
        // choose random direction, have dino face that direction
        // check the bounds, if its near DONT go that way
        // figure out rotation
        // this is the ugliest thing ive ever created
        if (contact.bodyA.categoryBitMask == PhysicsCategory.red.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.ground.rawValue) || (contact.bodyA.categoryBitMask == PhysicsCategory.red.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.blocks.rawValue) || (contact.bodyA.categoryBitMask == PhysicsCategory.red.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.ceiling.rawValue) {
            print("reddino HERE")
            
            var atTop = false
            var atLeft = false
            var atRight = false
            var atBottom = false
            
            // return to original
            if redCurrentDir == 1 {
                self.red.xScale = self.red.xScale * -1.0
            }
            if redCurrentDir == 3 {
                red.physicsBody?.allowsRotation = true
                red.run(SKAction.rotate(byAngle: CGFloat(Double.pi / -2.0), duration: 0.01))
                red.physicsBody?.allowsRotation = false
            }
            if redCurrentDir == 4 {
                red.physicsBody?.allowsRotation = true
                red.run(SKAction.rotate(byAngle: CGFloat(Double.pi / 2.0), duration: 0.01))
                red.physicsBody?.allowsRotation = false
            }
            
            
            let yspot = red.position.y
            let xspot = red.position.x
            
            red.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
            if yspot >= testGrid[129].location.y-20 {
                atTop = true
//                red.position = CGPoint(x: xspot, y: yspot-10) // move away from ceiling
            }
            
            if yspot <= testGrid[5].location.y+20 {
                atBottom = true
//                red.position = CGPoint(x: xspot, y: yspot+10) // move up from floor
            }
            
            if xspot <= testGrid[129].location.x+20 {
                atLeft = true
//                red.position = CGPoint(x: xspot+10, y: yspot) // move from left side
            }
            
            if xspot >= testGrid[143].location.x-20 {
                atRight = true
//                red.position = CGPoint(x: xspot-10, y: yspot)
            }
            // random direction, not last direction?
            var stupid = 0
            while stupid == 0 {
            let rand = Int(arc4random_uniform(4)) + 1
            if rand == 1 && redCurrentDir != 1 && !atLeft{
                // left
                red.physicsBody?.velocity = (CGVector(dx: -70, dy: 0))
                self.red.xScale = self.red.xScale * -1.0
                redCurrentDir = 1
                stupid = 1
            }
            if (rand == 2) && redCurrentDir != 2 && !atRight{
                // right
                red.physicsBody?.velocity = (CGVector(dx: 70, dy: 0))
//                self.red.xScale = self.red.xScale * -1.0
                redCurrentDir = 2
                stupid = 1
            }
            if rand == 3 && redCurrentDir != 3 && !atTop{
                // up
                red.physicsBody?.allowsRotation = true
                red.run(SKAction.rotate(byAngle: CGFloat(Double.pi / 2.0), duration: 0.01))
                red.physicsBody?.allowsRotation = false
                red.physicsBody?.velocity = (CGVector(dx: 0, dy: 70))
                redCurrentDir = 3
                stupid = 1
            }
            if rand == 4 && redCurrentDir != 4 && !atBottom{
                // down
                red.physicsBody?.allowsRotation = true
                red.run(SKAction.rotate(byAngle: CGFloat(Double.pi / -2.0), duration: 0.01))
                red.physicsBody?.allowsRotation = false
//                red.zRotation = CGFloat(Double.pi/2.0) * -1
                
                red.physicsBody?.velocity = (CGVector(dx: 0, dy: -70))
                
                stupid = 1
                redCurrentDir = 4
            }
            }
            

        } else if (contact.bodyB.categoryBitMask == PhysicsCategory.red.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.ground.rawValue) || (contact.bodyB.categoryBitMask == PhysicsCategory.red.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.blocks.rawValue) || (contact.bodyB.categoryBitMask == PhysicsCategory.red.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.ceiling.rawValue){
            print("reddino HERE")
            
            var atTop = false
            var atLeft = false
            var atRight = false
            var atBottom = false
            
            if redCurrentDir == 1 {
                self.red.xScale = self.red.xScale * -1.0
            }
            if redCurrentDir == 3 {
                red.physicsBody?.allowsRotation = true
                red.run(SKAction.rotate(byAngle: CGFloat(Double.pi / -2.0), duration: 0.01))
                red.physicsBody?.allowsRotation = false
            }
            if redCurrentDir == 4 {
                red.physicsBody?.allowsRotation = true
                red.run(SKAction.rotate(byAngle: CGFloat(Double.pi / 2.0), duration: 0.01))
                red.physicsBody?.allowsRotation = false
            }
            
            
            
            let yspot = red.position.y
            let xspot = red.position.x
            
            red.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
            if yspot >= testGrid[129].location.y-20 {
                print("wtf does this work!?") // then he cant go up!!!
                atTop = true
//                red.position = CGPoint(x: xspot, y: yspot-10) // move away from ceiling
            }
            
            if yspot <= testGrid[5].location.y+20 {
                atBottom = true
//                red.position = CGPoint(x: xspot, y: yspot+10) // move up from floor
            }
            
            if xspot <= testGrid[129].location.x+20 {
                atLeft = true
//                red.position = CGPoint(x: xspot+10, y: yspot) // move from left side
            }
            
            if xspot >= testGrid[143].location.x-20 {
                atRight = true
//                red.position = CGPoint(x: xspot-10, y: yspot)
            }
            
            var stupid = 0
            while stupid == 0 {
                let rand = Int(arc4random_uniform(4)) + 1
                if rand == 1 && redCurrentDir != 1 && !atLeft{
                    // left
                    red.physicsBody?.velocity = (CGVector(dx: -70, dy: 0))
                    self.red.xScale = self.red.xScale * -1.0
                    redCurrentDir = 1
                    stupid = 1
                }
                if (rand == 2) && redCurrentDir != 2 && !atRight{
                    // right
                    red.physicsBody?.velocity = (CGVector(dx: 70, dy: 0))
//                    self.red.xScale = self.red.xScale * -1.0
                    redCurrentDir = 2
                    stupid = 1
                }
                if rand == 3 && redCurrentDir != 3 && !atTop{
                    // up
                    red.physicsBody?.allowsRotation = true
                    red.run(SKAction.rotate(byAngle: CGFloat(Double.pi / 2.0), duration: 0.01))
                    red.physicsBody?.allowsRotation = false
                    red.physicsBody?.velocity = (CGVector(dx: 0, dy: 70))
                    redCurrentDir = 3
                    stupid = 1
                }
                if rand == 4 && redCurrentDir != 4 && !atBottom{
                    // down
                    red.physicsBody?.allowsRotation = true
                    red.run(SKAction.rotate(byAngle: CGFloat(Double.pi / -2.0), duration: 0.01))
                    red.physicsBody?.allowsRotation = false
                    red.physicsBody?.velocity = (CGVector(dx: 0, dy: -70))
                    stupid = 1
                    redCurrentDir = 4
                }
            }
        }
        if (contact.bodyA.categoryBitMask == PhysicsCategory.red.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.man.rawValue) {
            //            print("rex HERE")
            removeLife(100)
            
        } else if (contact.bodyB.categoryBitMask == PhysicsCategory.red.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.man.rawValue) {
            //            print("rex HERE")
            removeLife(100)
        }
        
        
        
        // FLy
        if (contact.bodyA.categoryBitMask == PhysicsCategory.fly.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.ground.rawValue) {
            print("fly HERE")
            fly.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
            self.flyDir = self.flyDir * -1
            self.fly.physicsBody?.velocity = CGVector(dx: self.flyDir, dy: 0)
        } else if (contact.bodyB.categoryBitMask == PhysicsCategory.fly.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.ground.rawValue) {
            print("fly HERE")
            fly.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
            self.flyDir = self.flyDir * -1
            self.fly.physicsBody?.velocity = CGVector(dx: self.flyDir, dy: 0)
        }
        
        // fireball
        if (contact.bodyA.categoryBitMask == PhysicsCategory.fireBall.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.subfloor.rawValue) {
//            print("rex HERE")
            let node = contact.bodyA.node
            node?.removeFromParent()
            
            
        } else if (contact.bodyB.categoryBitMask == PhysicsCategory.fireBall.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.subfloor.rawValue) {
//            print("rex HERE")
            let node = contact.bodyB.node
            node?.removeFromParent()
        }
        if (contact.bodyA.categoryBitMask == PhysicsCategory.fireBall.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.man.rawValue) {
            //            print("rex HERE")
            removeLife(100)
            
        } else if (contact.bodyB.categoryBitMask == PhysicsCategory.fireBall.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.man.rawValue) {
            //            print("rex HERE")
            removeLife(100)
        }
        
        // star
        if (contact.bodyA.categoryBitMask == PhysicsCategory.star.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.man.rawValue) {
            //            print("rex HERE")
            star.removeFromParent()
            testGrid[starLoc].occupied = false
            curscore += 1
            spawnStar()
            
            
        } else if (contact.bodyB.categoryBitMask == PhysicsCategory.star.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.man.rawValue) {
            //            print("rex HERE")
            star.removeFromParent()
            testGrid[starLoc].occupied = false
            curscore += 1
            spawnStar()
        }
        
        // food
        if (contact.bodyA.categoryBitMask == PhysicsCategory.food.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.man.rawValue) {
            //            print("rex HERE")
            food.removeFromParent()
            testGrid[foodLoc].occupied = false
            addLife()
            spawnFood()
            
            
        } else if (contact.bodyB.categoryBitMask == PhysicsCategory.food.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.man.rawValue) {
            //            print("rex HERE")
            food.removeFromParent()
            testGrid[foodLoc].occupied = false
            addLife()
            spawnFood()
        }
        
        if (contact.bodyA.categoryBitMask == PhysicsCategory.food.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.rex.rawValue) || (contact.bodyA.categoryBitMask == PhysicsCategory.food.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.red.rawValue) || (contact.bodyA.categoryBitMask == PhysicsCategory.food.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.stega.rawValue) {
            //            print("rex HERE")
            food.removeFromParent()
            testGrid[foodLoc].occupied = false
            let delay = DispatchTime.now() + 10.0
            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.spawnFood()}
            
            
        } else if (contact.bodyB.categoryBitMask == PhysicsCategory.food.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.rex.rawValue) || (contact.bodyB.categoryBitMask == PhysicsCategory.food.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.red.rawValue) || (contact.bodyB.categoryBitMask == PhysicsCategory.food.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.stega.rawValue){
            //            print("rex HERE")
            food.removeFromParent()
            testGrid[foodLoc].occupied = false
            let delay = DispatchTime.now() + 10.0
            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.spawnFood()}
        }

        // rocks
        if (contact.bodyA.categoryBitMask == PhysicsCategory.rock.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.stega.rawValue) || (contact.bodyB.categoryBitMask == PhysicsCategory.rock.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.stega.rawValue) {
            label.text = "You Killed The Yellow Dino!"
            dino.removeFromParent()
//            print("HIT")
            let rand = Int(arc4random_uniform(5)) + 1
            let delay = DispatchTime.now() + Double(rand)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.spawnStega()}
            
        }
        
        if (contact.bodyA.categoryBitMask == PhysicsCategory.rock.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.rex.rawValue) || (contact.bodyB.categoryBitMask == PhysicsCategory.rock.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.rex.rawValue) {
            label.text = "You DESTROYED T-REX!!"
            rex.removeFromParent()
//            print("HIT")
            let rand = Int(arc4random_uniform(5)) + 1
            let delay = DispatchTime.now() + Double(rand)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.spawnRex()}
            
        }
        
        if (contact.bodyA.categoryBitMask == PhysicsCategory.rock.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.red.rawValue) || (contact.bodyB.categoryBitMask == PhysicsCategory.rock.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.red.rawValue) {
            label.text = "You Killed The Illusive RED"
            red.removeFromParent()
            //            print("HIT")
            let rand = Int(arc4random_uniform(5)) + 1
            let delay = DispatchTime.now() + Double(rand)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.spawnRed()}
            
        }

        if (contact.bodyA.categoryBitMask == PhysicsCategory.rock.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.fireBall.rawValue) {
            
            label.text = "You Quinched The Fire"
            if let ball = contact.bodyB.node{
                ball.removeFromParent()}
        }
        else if(contact.bodyB.categoryBitMask == PhysicsCategory.rock.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.fireBall.rawValue) {
            
            label.text = "You Blew Out The Fire"
            if let ball = contact.bodyB.node{
                ball.removeFromParent()}
        }

        
        
        
        
}

    func leftSwipe(){ man.physicsBody?.velocity = (CGVector(dx: -100, dy: 0)) }
    
    func rightSwipe(){ man.physicsBody?.velocity = (CGVector(dx: 100, dy: 0)) }
    
    func upSwipe(){ man.physicsBody?.velocity = (CGVector(dx: 0, dy: 100)) }
    
    func downSwipe(){man.physicsBody?.velocity = (CGVector(dx: 0, dy: -100)) }
    
    func addLife() {
        life += 50
        if life > 300 {
            life = 300
        }
    }
    
    func removeLife(_ dmg: Int){
        life -= dmg
        if life <= 0 {
            GameOverMan()
        }
    }
    
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
        ceiling.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 2*self.frame.width, height: 3))
        ceiling.physicsBody?.isDynamic = false
        ceiling.physicsBody?.categoryBitMask = PhysicsCategory.ceiling.rawValue
//        ceiling.physicsBody?.contactTestBitMask = PhysicsCategory.man.rawValue
        addChild(ceiling)
        
        let wallLeft = SKNode()
        wallLeft.position = CGPoint(x: size.width, y: 0)
        wallLeft.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 5, height: 2*self.frame.height))
        wallLeft.physicsBody?.isDynamic = false
        wallLeft.physicsBody?.categoryBitMask = PhysicsCategory.ground.rawValue
        addChild(wallLeft)
        
        let wallRight = SKNode()
        wallRight.position = CGPoint(x: 0, y: 0)
        wallRight.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 5, height: 2*self.frame.height))
        wallRight.physicsBody?.isDynamic = false
        wallRight.physicsBody?.categoryBitMask = PhysicsCategory.ground.rawValue
        addChild(wallRight)
    }
    
    
    // this logic came from reywenderlich.com
    func adds(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    
    func subs(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
    
    func mult(point: CGPoint, scalar: CGFloat) -> CGPoint {
        return CGPoint(x: point.x * scalar, y: point.y * scalar)
    }
    
    func divs(point: CGPoint, scalar: CGFloat) -> CGPoint {
        return CGPoint(x: point.x / scalar, y: point.y / scalar)
    }
    
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
    
    func len(off: CGPoint) -> CGFloat {
        let x = off.x
        let y = off.y
        return sqrt(a: (x*x + y*y))
    }
    
    func norm(off: CGPoint) -> CGPoint {
        return divs(point: off, scalar: len(off: off))
    }
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        

        let rock = SKSpriteNode(imageNamed: "rock")
        rock.position = man.position
        rock.size = CGSize(width: bsize, height: bsize)
        rock.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bsize, height: bsize))
        rock.physicsBody?.affectedByGravity = false
        rock.physicsBody?.collisionBitMask = 0
        rock.physicsBody?.categoryBitMask = PhysicsCategory.rock.rawValue
//        rock.physicsBody?.contactTestBitMask = PhysicsCategory.stega.rawValue
        rock.physicsBody?.contactTestBitMask = PhysicsCategory.red.rawValue | PhysicsCategory.rex.rawValue | PhysicsCategory.fireBall.rawValue | PhysicsCategory.stega.rawValue
        let offset = subs(left: touchLocation, right: rock.position)
        

        addChild(rock)
        let direction = norm(off: offset)
        let shootAmount =  mult(point: direction,  scalar: 1000)
        
        let realDest = adds(left: shootAmount, right: rock.position)
        // constant speed
        let actionMove = SKAction.move(to: realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        rock.run(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    func GameOverMan() {
        self.removeAllChildren()
        dmgTime.invalidate()
        let flipTransition = SKTransition.doorsCloseHorizontal(withDuration: 2.0)
        let gameOverScene = GameOver(size: self.size, score: curscore)
        gameOverScene.scaleMode = .aspectFill
    
        self.view?.presentScene(gameOverScene, transition: flipTransition)

    }
    
    
    enum PhysicsCategory : UInt32 {
        case man = 1
        case rex = 2
        case blocks = 4
        case ground = 8
        case ceiling = 16
        case water = 32
        case stega = 64
        case subfloor = 128
        case red = 256
        case fly = 512
        case fireBall = 1024
        case star = 2048
        case food = 4096
        case rock = 8192
    }
}
