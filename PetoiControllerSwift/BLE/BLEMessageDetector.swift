//
//  Detector.swift
//  PetoiControllerSwift
//
// 后台线程，专门用于接收来自蓝牙的数据，轮询间隔默认为100ms
//
//  Created by Orlando Chen on 2021/3/29.
//

import Foundation

class BLEMessageDetector
{
    private var millisecond: Int!
    private var timer : Timer?
    private var running: Bool!
    
    // wake up the program every 100 milliseconds
    init(millisecond: Int = 100) {
        self.millisecond = millisecond
        self.running = false
    }
    
    func startListen(target aTarget: Any, selector aSelector: Selector) {
        
        // create timer thread
        timer = Timer.scheduledTimer(timeInterval: 1.0 / 1000.0 * Double(millisecond),
                                     target: aTarget, selector: aSelector,
                                     userInfo: nil, repeats: true)
        
        // start timer
        timer?.fire()
        running = true
    }
    
    func stopListen() {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        
        running = false
    }
    
    func isRunning() -> Bool {
        return running
    }
}
