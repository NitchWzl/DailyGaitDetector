//
//  ContentView.swift
//  WatchGaitDetector Watch App
//
//  Created by Zhuoli Wang on 2024/01/11.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var motionManager = WatchMotionManager.shared


    var body: some View {
        VStack {
            Text("Gait Detector Watch")
                .font(.headline)
            
            Spacer()
            
            Button("Start Sync") {
                // Handle the sync button tap
                motionManager.startMotionUpdates()
                motionManager.syncMotionData()
            }
            .buttonStyle(.bordered)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
