//
//  GameScene.swift
//  FlappyBird
//
//  Created by 岡本 翔真 on 2020/04/20.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // SKView上にシーンが表示されたときに呼ばれるメソッド
    override func didMove(to view: SKView) {
        //背景色
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        //地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest
        
        //テクスチャを指定してスプライトを作成する
        let groundSprite = SKSpriteNode(texture: groundTexture)
        
        //スプライトの表示を指定する
        groundSprite.position = CGPoint(x: groundTexture.size().width / 2, y: groundTexture.size().height / 2)
        
        //シーンにスプライトを追加
        addChild(groundSprite)
    }
}
