//
//  GameOver.swift
//  SpriteKitEx1
//
//  Created by Vitor Kawai Sala on 04/05/15.
//  Copyright (c) 2015 Vitor Kawai Sala. All rights reserved.
//

import SpriteKit

class GameOver : SKScene{

    init(size: CGSize, won: Bool) {
        super.init(size: size)

        backgroundColor = SKColor.whiteColor()

        var message = won ? "YEAAAH!!" : "NOOOOO!! 😰"

        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.blackColor()
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)

        runAction(
            SKAction.sequence([
                SKAction.waitForDuration(3),
                SKAction.runBlock({ () -> Void in
                    let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                    let scene = GameScene(size: size)
                    self.view?.presentScene(scene,transition: reveal)
                })
                ]
            )
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Nem ta implementado")
    }

}
