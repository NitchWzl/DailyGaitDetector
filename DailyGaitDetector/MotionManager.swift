////
////  MotionManager.swift
////  DailyGaitDetector
////
////  Created by Zhuoli Wang on 2023/12/26.
////
//
//import CoreMotion
//
//class MotionManager: ObservableObject {
//    private let motionManager = CMMotionManager()
//    @Published var motionData: [MotionData] = []  // record IMU data
//
//    func startUpdates() {
//        guard motionManager.isDeviceMotionAvailable else {
//            print("Device motion is not available")
//            return
//        }
//
//        motionManager.deviceMotionUpdateInterval = 0.1  // 设置更新频率，单位为秒
//
//        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (data, error) in
//            if let error = error {
//                print("Error updating motion data: \(error.localizedDescription)")
//                return
//            }
//
//            // 处理加速度计和陀螺仪数据
//            if let acceleration = data?.userAcceleration,
//               let rotationRate = data?.rotationRate {
//                let motionDataPoint = MotionData(acceleration: acceleration, rotationRate: rotationRate)
//                self.motionData.append(motionDataPoint)
//            }
//        }
//    }
//
//    func stopUpdates() {
//        motionManager.stopDeviceMotionUpdates()
//        print("Motion Data Recorded:")
//        print(motionData)
//    }
//}
//
//// data
//struct MotionData {
//    var acceleration: CMAcceleration
//    var rotationRate: CMRotationRate
//}
