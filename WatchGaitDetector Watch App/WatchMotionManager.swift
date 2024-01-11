//
//  WatchMotionManager.swift
//  WatchGaitDetector Watch App
//
//  Created by Zhuoli Wang on 2024/01/11.
//

import Foundation
import CoreMotion

class WatchMotionManager: ObservableObject {
    static let shared = WatchMotionManager()
        
    private var motionManager = CMMotionManager()
    private var syncTimer: Timer?

    @Published var motionData: [MotionData] = []
    
    private init() {}
    
    func startMotionUpdates() {
       guard motionManager.isDeviceMotionAvailable else {
           print("Device motion is not available")
           return
       }
       
       motionManager.deviceMotionUpdateInterval = 1.0 / 30.0 // 30 Hz
       motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (motion, error) in
           guard let motion = motion, error == nil else { return }
           
           let motionDataPoint = MotionData(timestamp: Date(), motion: motion)
           self.motionData.append(motionDataPoint)
       }
   }
    
    func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    // Function to sync motion data with the paired iPhone
    func syncMotionData() {
        // Implement data synchronization logic here
        // You can use URLSession or other methods to send data to the iPhone app
        // Example: Send self.motionData to the iPhone
        
        // After syncing, you might want to reset the motionData array
        motionData.removeAll()
    }
}

struct MotionData {
    let timestamp: Date
    let motion: CMDeviceMotion
}
