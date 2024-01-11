//
//  ContentView.swift
//  DailyGaitDetector
//
//  Created by Zhuoli Wang on 2023/12/25.
//

import SwiftUI
import CoreMotion
import HealthKit
import MessageUI
import WatchConnectivity
//import SwiftUICharts

//class WatchSessionDelegate: NSObject, ObservableObject, WCSessionDelegate {
//    func sessionDidBecomeInactive(_ session: WCSession) {
//        <#code#>
//    }
//    
//    func sessionDidDeactivate(_ session: WCSession) {
//        <#code#>
//    }
//    
//    @Published var receivedData: YourExerciseDataModel?
//
//    // Implement WCSessionDelegate methods...
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//        // Handle session activation completion
//    }
//
//    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
//        do {
//            if let receivedData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(messageData) as? YourExerciseDataModel {
//                DispatchQueue.main.async {
//                    self.receivedData = receivedData
//                }
//            }
//        } catch {
//            print("Error unarchiving data: \(error.localizedDescription)")
//        }
//    }
//}

struct ContentView: View {
    @State private var isRecording = false
    @State private var imuData = "No data"
    @State private var motionManager = CMMotionManager()
    @State private var healthStore = HKHealthStore()
    @State private var recordingFrequency: Double = 60 // Default frequency is 60 Hz
    @State private var recordedData: [String] = []
    
//    init() {
//        // Setup Watch Connectivity
//        if WCSession.default.isSupported {
//            WCSession.default.delegate = watchSessionDelegate
//            WCSession.default.activate()
//        }
//    }

    
    var body: some View {
        VStack {
            Text("IMU Data: \(imuData)")
                            .padding()
            Button(action:{
                if isRecording {stopRecording()}
                else {startRecording()}
            }){
                if isRecording{Text("Stop Recording")}
                else {Text("Start Recording")}
            }
            
            Slider(value: Binding(get: {
                self.recordingFrequency
            }, set: { newValue in
                self.recordingFrequency = newValue
                stopMotionUpdates()
                startMotionUpdates()
            }), in: 40...100, step: 10)
                .padding()
            Text("Recording Frequency: \(Int(recordingFrequency)) Hz")
        }
        .onAppear {
            startMotionUpdates()
        }
        .onDisappear {
            stopMotionUpdates()
        }
    }
    private func startMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / recordingFrequency
            
            motionManager.startDeviceMotionUpdates(to: .main) { (data, error) in
                if let motionData = data {
                    // Access different motion data properties
                    let pitch = motionData.attitude.pitch
                    let roll = motionData.attitude.roll
                    let yaw = motionData.attitude.yaw

                    let angularVelocityX = motionData.rotationRate.x
                    let angularVelocityY = motionData.rotationRate.y
                    let angularVelocityZ = motionData.rotationRate.z
                    let accelerationX = motionData.userAcceleration.x
                    let accelerationY = motionData.userAcceleration.y
                    let accelerationZ = motionData.userAcceleration.z

            
                    imuData = """
                        Pitch: \(pitch)
                        Roll: \(roll)
                        Yaw: \(yaw)
                        Angular Velocity:
                        X: \(angularVelocityX)
                        Y: \(angularVelocityY)
                        Z: \(angularVelocityZ)
                        \nAcceleration: X: \(accelerationX), Y: \(accelerationY), Z: \(accelerationZ)
                    """
                    
                    if isRecording {
                        // Collect data for recording
                        let recordLine = "\(pitch),\(roll),\(yaw),\(angularVelocityX),\(angularVelocityY),\(angularVelocityZ),\(accelerationX),\(accelerationY),\(accelerationZ)"
                        recordedData.append(recordLine)
                    }
                }
            }
        }
    }

    private func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    private func startRecording() {
        isRecording = true
        recordedData.removeAll()
        requestHealthKitAuthorization()
    }
    
    private func stopRecording() {
        isRecording = false
        print("push stop")
        saveDataToCSV()
        shareData()
        // code: share the data with email or message or other chat
    }
    
    private func saveDataToCSV() {
        guard !recordedData.isEmpty else {
            return
        }

        let fileName = "recorded_data.csv"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try recordedData.joined(separator: "\n").write(to: path, atomically: true, encoding: .utf8)
            // Here you can add code to share the file or perform other actions
            print("Data saved to: \(path)")
        } catch {
            print("Error saving data to CSV: \(error).")
        }
    }

    private func shareData() {
       guard let url = URL(string: "file://\(FileManager.default.temporaryDirectory.path)/recorded_data.csv") else {
           print("Invalid file URL")
           return
       }
       
       let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
       UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
   }
    
    private func requestHealthKitAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }

        let typesToShare: Set<HKSampleType> = []
        let typesToRead: Set<HKObjectType> = [HKObjectType.workoutType(), HKSeriesType.workoutRoute()]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if success {
                print("HealthKit authorization granted.")
                self.queryWorkouts()
            } else {
                print("HealthKit authorization denied.")
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }

    private func queryWorkouts() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }

        let workoutType = HKObjectType.workoutType()
        let predicate = HKQuery.predicateForWorkouts(with: .running)
        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, samples, error in
            if let error = error {
                print("Error querying workouts: \(error.localizedDescription)")
                return
            }

            if let workouts = samples as? [HKWorkout] {
                for workout in workouts {
                    // Process workout data
                    print("Workout: \(workout)")
                }
            }
        }

        healthStore.execute(query)
    }

}


#Preview {
    ContentView()
}

      
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
