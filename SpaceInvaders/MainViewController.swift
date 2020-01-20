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
    
    let fireView = UIView()
    
    var blockViews = [UIView]()
    
    var isFire: Bool = false
    
    let playerEmiter = Emiter()

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
        
        fireView.backgroundColor = .red
        view.addSubview(fireView)
        
        playerEmiter.view = fireView
        playerEmiter.yOffset = 1.0
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
        if !isFire {
            fireView.frame = CGRect(x: playerView.frame.minX, y: playerView.frame.minY - Constants.Fire.size, width: Constants.Fire.size, height: Constants.Fire.size)
            playerEmiter.start()
            isFire = true
        }
    }
    
    func emiter(_ emiter: Emiter, didMoveView v: UIView) {
        if v.frame.minY < -v.frame.width {
            playerEmiter.stop()
            isFire = false
        } else if let block = blockViews.filter({v.frame.minY <= $0.frame.maxY && v.frame.maxX > $0.frame.minX && v.frame.minX < $0.frame.maxX}).first {
            block.removeFromSuperview()
            blockViews.removeAll(where: {block == $0})
            playerEmiter.stop()
            isFire = false
        }
        
        if blockViews.isEmpty {
            blindView?.isHidden = false
        }
    }
    
    @IBAction func startButtonTap(sender: UIButton) {
        blindView?.isHidden = true
        placeBlocks()
    }
    
    func placeBlocks() {
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

    }
}
