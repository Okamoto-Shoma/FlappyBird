//
//  GameScene.swift
//  FlappyBird
//
//  Created by 岡本 翔真 on 2020/04/20.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scrollNode: SKNode!
    var wallNode: SKNode!
    var bird:SKSpriteNode!
    //課題アイテム用
    var coinNode: SKSpriteNode!
    
    //スコア用
    var score = 0
    var scoreLabelNode: SKLabelNode!
    var bestScoreLabelNode: SKLabelNode!
    //課題アイテム用
    var coin = 0
    var coinScoreLabelNode: SKLabelNode!
    
    let userDefaults: UserDefaults = UserDefaults.standard
    
    //衝突判定カテゴリー
    let birdCategory: UInt32 = 1 << 0
    let groundCategory: UInt32 = 1 << 1
    let wallCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    //課題アイテム用
    let coinCategory: UInt32 = 1 << 4
    
//MARK: -Life Cycle
    
    // SKView上にシーンが表示されたときに呼ばれるメソッド
    override func didMove(to view: SKView) {
        
        //重力を設定
        physicsWorld.gravity = CGVector(dx: 0, dy: -4)
        physicsWorld.contactDelegate = self
        
        //背景色
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        //スクロールする親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        
        //壁用のノード
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        //課題アイテム用
        coinNode = SKSpriteNode()
        scrollNode.addChild(coinNode)
        
        
        //各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupScoreLabel()
        
        //課題アイテム用
        setupCoin()
    }
    
    
    /// 画面タップ時の処理
    /// - Parameter touches: <#touches description#>
    /// - Parameter event: <#event description#>
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scrollNode.speed > 0 {
            //鳥の速度をゼロにする
            bird.physicsBody?.velocity = CGVector.zero
        
            //鳥に縦方向の力を与える
            bird.physicsBody?.applyImpulse(CGVector(dx:0, dy:15))
        } else {
            restart()
        }
    }
    
//MARK: -Method
    
    
    /// 地面処理
    func setupGround() {
        //地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest
        
        //必要な枚数を計算
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        
        //スクロールするアクションを作成
        //左方向に画像一愛分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
        
        //の元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        
        //左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        
        //groundのスプライトを配置する
        for i in 0 ..< needNumber {
            let sprite = SKSpriteNode(texture: groundTexture)
            
            //スプライトの表示する位置を指定する
            sprite.position = CGPoint(x: groundTexture.size().width / 2 + groundTexture.size().width * CGFloat(i), y: groundTexture.size().height / 2)
        
            //スプライトにアクションを設定
            sprite.run(repeatScrollGround)
            
            //スプライトに物理演算を設定
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            
            //衝突カテゴリー設定
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            //衝突の時に動かないように設定
            sprite.physicsBody?.isDynamic = false
            
            //スプライトを追加
            scrollNode.addChild(sprite)
        }
    }
    
    
    /// 雲の処理
    func setupCloud() {
        // 雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest

        // 必要な枚数を計算
        let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2

        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width , y: 0, duration: 20)

        // 元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)

        // 左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))

        // スプライトを配置する
        for i in 0 ..< needCloudNumber {
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100 // 一番後ろになるようにする

            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: cloudTexture.size().width / 2 + cloudTexture.size().width * CGFloat(i),
                y: self.size.height - cloudTexture.size().height / 2
            )

            // スプライトにアニメーションを設定する
            sprite.run(repeatScrollCloud)

            // スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    
    /// 壁の処理
    func setupWall() {
        //壁の画像読み込み
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear
        
        //移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        
        //画面外まで移動するアクション
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4)
        
        //自身を取り除くアクション
        let removeWall = SKAction.removeFromParent()
        
        //2つのアニメーションを順に実行するアクション
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        //鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        
        //鳥が通り抜ける隙間の長さを鳥のサイズの3倍とする
        let slit_length = birdSize.height * 3
        
        //隙間位置の上下の振れ幅を鳥のサイズの3倍とする
        let random_y_range = birdSize.height * 3
        
        //下の壁のY軸下限位置
        let groundSize = SKTexture(imageNamed: "ground").size()
        let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        let under_wall_lowest_y = center_y - slit_length / 2 - wallTexture.size().height / 2 - random_y_range / 2
        
        //壁を生成するアクション
        let createWallAnimation = SKAction.run ({
            //壁関連のノードを乗せるノード
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0)
            wall.zPosition = -50 //雲より手前、地面より奥
            
            //0~random_y_rangeまでのランダム値生成
            let random_y = CGFloat.random(in: 0 ..< random_y_range)
            //Y軸の下限にランダムな値を足して、下の壁のY座標を決定
            let under_wall_y = under_wall_lowest_y + random_y
            
            //下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0, y: under_wall_y)
            
            //スプライトに物理演算を設定
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            
            //衝突時に動かないよう設定
            under.physicsBody?.isDynamic = false
            
            wall.addChild(under)
            
            //上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            //スプライトに物理演算を設定
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory
            
            //衝突時動かないよう設定
            upper.physicsBody?.isDynamic = false
            
            wall.addChild(upper)
            
            //スコアアップ用のノード
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y: self.frame.height / 2)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(scoreNode)
            
            wall.run(wallAnimation)
            self.wallNode.addChild(wall)
        })
        
        //次の壁作成までの時間待ちのアクション作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        //壁を作成->時間待ち->壁を作成を無限に繰り返すアクション
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        wallNode.run(repeatForeverAnimation)
    }
    
    ///課題アイテム用処理
    func setupCoin() {
        let coinTexture = SKTexture (imageNamed: "coin")
        coinTexture.filteringMode = .linear
        
        //移動する距離を計算
        let coinMoveDistance = CGFloat(self.frame.size.width + coinTexture.size().width)
        //移動するアクション
        let moveCoin = SKAction.moveBy(x: -coinMoveDistance, y: 0, duration: 4)
        //自身を消す処理
        let removeCoin = SKAction.removeFromParent()
        //移動->消すの流れを順に処理
        let CoinAnimation = SKAction.sequence([moveCoin, removeCoin])
        //コインを生成する処理
        let createCoinAnimation = SKAction.run ({
            //コインの出現Y軸をランダムに
            let ramdom_y = CGFloat.random(in: coinTexture.size().height ..< self.frame.size.height / 2)
            //コイン関連のノードを乗せるノード
            let coin = SKNode()
            coin.position = CGPoint(x: self.frame.size.width, y: ramdom_y)
            coin.zPosition = -50
            
            //スプライトに物理演算を設定
            coin.physicsBody?.categoryBitMask = self.coinCategory
            
            //衝突時に動かないよう設定
            coin.physicsBody?.isDynamic = false
            
            //コイン作成
            let coinSprite = SKSpriteNode(texture: coinTexture)
            
            //コインスコアアップ用のノード
            coin.physicsBody = SKPhysicsBody(circleOfRadius: coinTexture.size().width / 2)
            coin.physicsBody?.isDynamic = false
            coin.physicsBody?.categoryBitMask = self.coinCategory
            coin.physicsBody?.contactTestBitMask = self.birdCategory
            
            coin.addChild(coinSprite)
            coin.run(CoinAnimation)
            self.coinNode.addChild(coin)
        })
        //次のコイン作成までの待ち時間アクション
        let waitCoinAnimation = SKAction.wait(forDuration: 3)
        //コイン作成->時間待ち->コイン作成を無限に繰り返すアクション
        let repeatCoinAnimation = SKAction.repeatForever(SKAction.sequence([createCoinAnimation, waitCoinAnimation]))
        //スプライトに追加
        coinNode.run(repeatCoinAnimation)
    }
    
    /// 鳥の処理
    func setupBird() {
        //鳥の画像を2種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        
        //2種類のテクスチャを交互に変更するアニメーション
        let texturesAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texturesAnimation)
        
        //スプライト作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        
        //物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        
        //衝突時に回転させない
        bird.physicsBody?.allowsRotation = false
        
        //衝突時のカテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory
        
        //アニメーションを設定
        bird.run(flap)
        
        //スプライトを追加
        addChild(bird)
    }
    
    /// リスタート
    func restart() {
        score = 0
        coin = 0
        scoreLabelNode.text = "Score:\(score)"
        coinScoreLabelNode.text = "Coin:\(coin)"
        
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0
        
        wallNode.removeAllChildren()
        coinNode.removeAllChildren()
        
        bird.speed = 1
        scrollNode.speed = 1
    }
    
    /// スコアラベル処理
    func setupScoreLabel() {
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score\(score)"
        
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        bestScoreLabelNode.zPosition = 100
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        
        self.addChild(bestScoreLabelNode)
        
        coinScoreLabelNode = SKLabelNode()
        coinScoreLabelNode.fontColor = UIColor.black
        coinScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 120)
        coinScoreLabelNode.zPosition = 100
        coinScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let CoinScore = userDefaults.integer(forKey: "coin")
        coinScoreLabelNode.text = "Coin:\(CoinScore)"
        
        self.addChild(coinScoreLabelNode)
    }
    
    //SKPhysicsContactDelegateのメソッド。衝突時に呼ばれる
    func didBegin(_ contact: SKPhysicsContact) {
        //ゲームオーバー時に何もしない
        if scrollNode.speed <= 0 {
            return
        }
        
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            //スコア用の物体と衝突
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"
            
            //ベストスコア更新か確認
            var bestScore = userDefaults.integer(forKey: "BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"
                userDefaults.set(bestScore, forKey: "BSET")
                userDefaults.synchronize()
            }
        } else if (contact.bodyA.categoryBitMask & coinCategory) == coinCategory || (contact.bodyB.categoryBitMask & coinCategory) == coinCategory {
            //コイン用の物体と衝突
            print("CoinUp")
            coin += 1
            coinScoreLabelNode.text = "Coin:\(coin)"
            
            //取得音用
            let getSound = SKAction.playSoundFileNamed("Shortbridge30-1.mp3", waitForCompletion: false)
            self.run(getSound)
            
            contact.bodyB.node?.removeFromParent()
            //取得音
            
        } else {
            //壁か地面と衝突
            print("GameOver")
            
            //スクロールを停止
            scrollNode.speed = 0
            
            bird.physicsBody?.collisionBitMask = groundCategory
            
            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration: 1)
            bird.run(roll, completion: {
                self.bird.speed = 0
            })
        }
    }
}
