//
//  GameScene.swift
//  Project17
//
//  Created by Артем Чжен on 02/05/23.
//

import SpriteKit
//import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    var possibleEnemies = ["ball", "hammer", "tv"]
    var gameTimer: Timer?
    var isGameOVer = false
    var enemyCount = 0
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        starfield = SKEmitterNode(fileNamed: "starfield")!
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed:  "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    @objc func createEnemy() {
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        
        enemyCount += 1
        if enemyCount % 20 == 0 {
            gameTimer?.invalidate()
            gameTimer = Timer.scheduledTimer(timeInterval: max(0.9, gameTimer!.timeInterval - 0.1), target: self, selector:  #selector(createEnemy), userInfo: nil, repeats: true)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        if !isGameOVer {
            score += 1
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        boom()
//        let explosion = SKEffectNode(fileNamed: "explosion")!
//        explosion.position = player.position
//        addChild(explosion)

        player.removeFromParent()
        isGameOVer = true
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            player.removeFromParent()
            starfield.removeFromParent()
            gameTimer?.invalidate()
            isGameOVer = true
//            let location = touch.location(in: self)
        }
        
        labelEndGame()
        boom()
    }
    
    func boom() {
        let explosion = SKEffectNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
    }
    func labelEndGame() {
        let finalScore = SKLabelNode(fontNamed: "Chalkduster")
        finalScore.text = "You lost, and you score: \(score)"
        finalScore.position = CGPoint(x: 512, y: 400)
        finalScore.zPosition = 1
        addChild(finalScore)
    }
}
