//
//  MainViewController.swift
//  SpaceInvaders
//
//  Created by Damon Cricket on 20.01.2020.
//  Copyright © 2020 DC. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, EmiterDelegate {
    struct Constants {
        struct Player {
            static let width: CGFloat = 35.0
            static let height: CGFloat = 80.0
        }
        struct Fire {
            static let size = Constants.Player.width
        }
    }
    
    @IBOutlet weak var blindView: UIView?
    
    @IBOutlet weak var startButton: UIButton?
    
    let playerView = UIView()
    
    let playerFireView = UIView()
    
    let enemyFireView = UIView()
    
    var blockViews = [UIView]()
    
    var isPlayerFire: Bool = false
    
    var isEmemyFire: Bool = false
    
    let playerEmiter = Emiter()
    
    var enemyRunTimer: Timer? = nil
    
    deinit {
        stopEnemyRunTimer()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startButton?.layer.borderColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0).cgColor
        startButton?.layer.borderWidth = 3.0
        startButton?.layer.cornerRadius = 3.0

        let playerX = (view.bounds.width - Constants.Player.width)/2.0
        let playerY = view.bounds.height - Constants.Player.height
        playerView.frame = CGRect(x: playerX, y: playerY, width: Constants.Player.width, height: Constants.Player.height)
        playerView.backgroundColor = .black
        view.addSubview(playerView)
        
        playerFireView.backgroundColor = .red
        view.addSubview(playerFireView)
        
        playerEmiter.view = playerFireView
        playerEmiter.yOffset = -1.0
        playerEmiter.delegate = self
        playerEmiter.timeInterval = 0.0005
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(recognizer:)))
        view.addGestureRecognizer(panGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer(recognizer:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func panGestureRecognizer(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: view)
        playerView.center = CGPoint(x: location.x, y: playerView.center.y)
        if playerView.frame.minX < 0.0 {
            playerView.frame = CGRect(x: 0.0, y: playerView.frame.minY, width: Constants.Player.width, height: Constants.Player.height)
        } else if playerView.frame.minX > view.bounds.width {
            playerView.frame = CGRect(x: view.bounds.width - Constants.Player.width, y: playerView.frame.minY, width: Constants.Player.width, height: Constants.Player.height)
        }
    }
    
    @objc func tapGestureRecognizer(recognizer: UITapGestureRecognizer) {
        if !isPlayerFire {
            playerFireView.frame = CGRect(x: playerView.frame.minX, y: playerView.frame.minY - Constants.Fire.size, width: Constants.Fire.size, height: Constants.Fire.size)
            playerEmiter.start()
            isPlayerFire = true
        }
    }
    
    func emiter(_ emiter: Emiter, didMoveView v: UIView) {
        if emiter == playerEmiter {
            if v.frame.minY < -v.frame.width {
                playerEmiter.stop()
                isPlayerFire = false
            } else if let block = blockViews.filter({v.frame.minY <= $0.frame.maxY && v.frame.maxX > $0.frame.minX && v.frame.minX < $0.frame.maxX}).first {
                block.removeFromSuperview()
                blockViews.removeAll(where: {block == $0})
                playerEmiter.stop()
                isPlayerFire = false
                playerFireView.frame = CGRect(x: playerFireView.frame.minX, y: view.bounds.height, width: Constants.Fire.size, height: Constants.Fire.size)
            }
            if blockViews.isEmpty {
                blindView?.isHidden = false
                stopEnemyRunTimer()
            }
        }
    }
    
    @IBAction func startButtonTap(sender: UIButton) {
        blindView?.isHidden = true
        for v in blockViews {
            v.removeFromSuperview()
        }
        blockViews.removeAll()
        var lastX: CGFloat = 0.0
        var lastY: CGFloat = UIApplication.shared.statusBarFrame.height
        for _ in 0 ..< 10 {
            let count = 5
            lastX = 0.0
            for _ in 0 ... count - 1 {
                let blockWidth = view.bounds.width / CGFloat(count)
                let blockView = UIView(frame: CGRect(x: lastX, y: lastY , width: blockWidth, height: 20.0))
                lastX = blockView.frame.maxX
                blockView.backgroundColor = .blue
                blockViews.append(blockView)
                view.addSubview(blockView)
            }
            lastY = blockViews.last!.frame.maxY
        }
        enemyRunTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(runTimerTick(timer:)), userInfo: nil, repeats: true)
    }
    
    @objc func runTimerTick(timer: Timer) {
        for block in blockViews {
            block.frame = CGRect(x: block.frame.minX, y: block.frame.minY + block.frame.height, width: block.frame.width, height: block.frame.height)
        }
        
        if let _ = blockViews.filter({$0.frame.maxY >= self.playerView.frame.minY}).first {
            stopEnemyRunTimer()
            blindView?.isHidden = false
            for block in blockViews {
                block.removeFromSuperview()
            }
            blockViews.removeAll()
        }
    }
    
    func stopEnemyRunTimer() {
        enemyRunTimer?.invalidate()
        enemyRunTimer = nil
    }
}
