//
//  Emiter.swift
//  SpaceInvaders
//
//  Created by Damon Cricket on 20.01.2020.
//  Copyright © 2020 DC. All rights reserved.
//

import Foundation
import UIKit

protocol EmiterDelegate: class {
    func emiter(_ emiter: Emiter, didMoveView view: UIView)
}

class Emiter {
    weak var delegate: EmiterDelegate?
    
    var view: UIView? = nil
    
    var timer: Timer? = nil
    
    var yOffset: CGFloat = 0.0
    
    var timeInterval: TimeInterval = 0.0
    
    deinit {
        view = nil
        stopTimer()
    }
    
    func start() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerTick(timer:)), userInfo: nil, repeats: true)
        }
    }
    
    @objc func timerTick(timer: Timer) {
        view?.frame = CGRect(x: view!.frame.minX, y: view!.frame.minY + yOffset, width: view!.frame.width, height: view!.frame.height)
        delegate?.emiter(self, didMoveView: view!)
    }
    
    func stop() {
        stopTimer()
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    static func ==(lhs: Emiter, rhs: Emiter) -> Bool {
        return lhs.view == rhs.view && lhs.timer == rhs.timer && lhs.yOffset == rhs.yOffset && lhs.yOffset == rhs.yOffset && lhs.timeInterval == rhs.timeInterval
    }
}
