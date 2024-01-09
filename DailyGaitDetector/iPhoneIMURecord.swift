////
////  iPhoneIMURecord.swift
////  DailyGaitDetector
////
////  Created by Zhuoli Wang on 2023/12/26.
////
//
//import Foundation
//import CoreMotion
//
//class IMUManager {
//    let motionManager = CMMotionManager()
//
//    func startUpdatingIMUData() {
//        if motionManager.isDeviceMotionAvailable {
//            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0  // 60 Hz
//            motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (motion, error) in
//                if let motion = motion {
//                    // Process motion data (acceleration, rotation rate, attitude)
//                    self.sendDataToComputer(motion: motion)
//                } else if let error = error {
//                    print("Error updating device motion: \(error.localizedDescription)")
//                }
//            }
//        } else {
//            print("Device motion is not available.")
//        }
//    }
//
//    func stopUpdatingIMUData() {
//        motionManager.stopDeviceMotionUpdates()
//    }
//
//    func sendDataToComputer(motion: CMDeviceMotion) {
//        // Prepare your data for transmission
//        let accelerometerData = motion.userAcceleration
//        let gyroscopeData = motion.rotationRate
//
//        // Example: Send data using URLSession
//        let url = URL(string: "http://your-computer-ip:your-port")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let dataToSend = ["acceleration": [accelerometerData.x, accelerometerData.y, accelerometerData.z],
//                          "rotationRate": [gyroscopeData.x, gyroscopeData.y, gyroscopeData.z]]
//
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: dataToSend, options: [])
//            request.httpBody = jsonData
//            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//                if let error = error {
//                    print("Error sending data to computer: \(error.localizedDescription)")
//                }
//            }
//            task.resume()
//        } catch {
//            print("Error serializing data: \(error.localizedDescription)")
//        }
//    }
//}
//
