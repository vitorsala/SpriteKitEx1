//
//  GameScene.swift
//  SpriteKitEx1
//
//  Created by Vitor Kawai Sala on 04/05/15.
//  Copyright (c) 2015 Vitor Kawai Sala. All rights reserved.
//

import SpriteKit
import AVFoundation

func + (p1: CGPoint, p2: CGPoint) -> CGPoint{
    return CGPoint(x: p1.x + p2.x, y: p1.y + p2.y)
}

func - (p1: CGPoint, p2: CGPoint) -> CGPoint{
    return CGPoint(x: p1.x - p2.x, y: p1.y - p2.y)
}

func * (p1: CGPoint, escalar: CGFloat) -> CGPoint{
    return CGPoint(x: p1.x * escalar, y: p1.y * escalar)
}

func / (p1: CGPoint, escalar: CGFloat) -> CGPoint{
    return CGPoint(x: p1.x / escalar, y: p1.y / escalar)
}

extension CGPoint{
    func length() -> CGFloat{
        return sqrt(x*x+y*y)
    }
    func normalized() -> CGPoint{
        return self/length()
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var destroyedMeteor = 0
    var lifes = 5

    let player = SKSpriteNode(imageNamed:"Spaceship")
    let pointsLabel = SKLabelNode(text: "Pontos: 0")
    let lifesLabel = SKLabelNode(text: "Vidas: 5")
    var backgroundMusicPlayer : AVAudioPlayer?

    struct NodeCategory {
        static let none : UInt32 = 0
        static let all : UInt32 = UInt32.max
        static let player : UInt32 = 0b1
        static let meteor : UInt32 = 0b10
        static let projectile : UInt32 = 0b100
    }

    override func didMoveToView(view: SKView) {
        size = CGSize(width: UIScreen.mainScreen().bounds.size.width * 2, height: UIScreen.mainScreen().bounds.size.height * 2)
        backgroundColor = SKColor.whiteColor()
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self

        self.bgMusic("8-punk-8-bit-music")

        // Points label setup
        pointsLabel.position = CGPoint(x: size.width/2, y: size.height*0.8)
        pointsLabel.fontColor = SKColor.blackColor()
        pointsLabel.fontName = "Chalkduster"

        addChild(pointsLabel)

        // Lifes label setup
        lifesLabel.position = CGPoint(x: size.width/2, y: size.height*0.9)
        lifesLabel.fontColor = SKColor.blackColor()
        lifesLabel.fontName = "Chalkduster"

        addChild(lifesLabel)
        
        // Player setup
        addPlayer()

        // Meteors setup
        runAction(
            SKAction.repeatActionForever(
                SKAction.sequence([
                    SKAction.runBlock(addMeteor),
                    SKAction.waitForDuration(1)
                ])
            )
        )
    }

    func addPlayer(){
//        player.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "Spaceship"), size: CGSize(width: player.size.width, height: player.size.height))
//        player.physicsBody?.categoryBitMask = NodeCategory.player
//        player.physicsBody?.collisionBitMask = NodeCategory.none

        player.xScale = 0.4
        player.yScale = 0.4
        player.position = CGPoint(x: self.size.width*0.1, y: self.size.height*0.5)
        player.zRotation = CGFloat(-90)*CGFloat(M_PI)/CGFloat(180)

        self.addChild(player)
    }

    func addMeteor(){

        let meteor = SKShapeNode(circleOfRadius: 40)
        meteor.physicsBody = SKPhysicsBody(circleOfRadius: 40)
        meteor.physicsBody?.categoryBitMask = NodeCategory.meteor
        meteor.physicsBody?.contactTestBitMask = NodeCategory.projectile
        meteor.physicsBody?.collisionBitMask = NodeCategory.none

        meteor.fillColor = SKColor.brownColor()

        meteor.position = CGPoint(x: size.width, y: random(min: meteor.frame.size.height/2, max: size.height - meteor.frame.size.height))

        addChild(meteor)

        //Actions para o meteoro
        let vel = random(min: 4, max: 6)
        let meteorAction = SKAction.moveTo(CGPoint(x: -meteor.frame.size.width,y: meteor.position.y), duration: NSTimeInterval(Int(vel)))
        let meteorDone = SKAction.removeFromParent()
        meteor.runAction(SKAction.sequence([meteorAction,SKAction.runBlock({ () -> Void in
            self.lifes--
            self.lifesLabel.text = "Vidas: \(self.lifes)"
            if self.lifes <= 0{
                self.backgroundMusicPlayer?.stop()
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                let gameOverScene = GameOver(size: self.size, won: false)
                self.view?.presentScene(gameOverScene, transition: reveal)
            }
        }),meteorDone]))
    }



    func random(#min: CGFloat, max: CGFloat) -> CGFloat{
        return CGFloat(arc4random()) % CGFloat(max - min) + CGFloat(min)
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {

        let touchLocation = (touches.first as! UITouch).locationInNode(self)

        let projectile = SKShapeNode(circleOfRadius: 5)
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        projectile.physicsBody?.categoryBitMask = NodeCategory.projectile
        projectile.physicsBody?.contactTestBitMask = NodeCategory.meteor
        projectile.physicsBody?.collisionBitMask = NodeCategory.none
        projectile.physicsBody?.usesPreciseCollisionDetection = true

        projectile.fillColor = SKColor.purpleColor()
        projectile.position = CGPoint(x: player.position.x+player.position.x/2, y: player.position.y)


        let vector = touchLocation - projectile.position
        if vector.x < 0{
            return
        }

        let direction = vector.normalized() * size.width + projectile.position

        addChild(projectile)

//        runAction(SKAction.playSoundFileNamed("Ima_Firin_My_Lazer.mp3", waitForCompletion: false))
        runAction(SKAction.playSoundFileNamed("Laser Blasts.mp3", waitForCompletion: false))
        let shootAction = SKAction.moveTo(direction, duration: 1)
        let shootDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([shootAction,shootDone]))
    }

    func didBeginContact(contact: SKPhysicsContact) {
        var first : SKPhysicsBody
        var second : SKPhysicsBody

        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
            first = contact.bodyA
            second = contact.bodyB
        }
        else {
            first = contact.bodyB
            second = contact.bodyA
        }

        if(first.categoryBitMask & NodeCategory.meteor != 0 && second.categoryBitMask & NodeCategory.projectile != 0){
            projectileDidContactWithMeteor(projectile: first.node!, meteor: second.node!)
        }
    }

    func projectileDidContactWithMeteor(#projectile : SKNode, meteor: SKNode){
        println("ROAR")
        projectile.removeFromParent()
        meteor.removeFromParent()
        destroyedMeteor++
        pointsLabel.text = "Pontos: \(destroyedMeteor)"
        if destroyedMeteor >= 20{
            backgroundMusicPlayer?.stop()
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOver(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }

    }

    func bgMusic(filename : String){
        let url = NSBundle.mainBundle().URLForResource(filename, withExtension: ".mp3")
        if url == nil{
            println("Nenhum som encontrado! 😧")
            return
        }
        var error : NSError? = nil
        backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
        if backgroundMusicPlayer == nil{
            println("Fail")
            return
        }
        backgroundMusicPlayer?.numberOfLoops = -1
        backgroundMusicPlayer?.prepareToPlay()
        backgroundMusicPlayer?.play()
    }

    override func update(currentTime: CFTimeInterval) {
    }
}
