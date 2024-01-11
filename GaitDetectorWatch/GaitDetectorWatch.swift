//
//  GaitDetectorWatch.swift
//  GaitDetectorWatch
//
//  Created by Zhuoli Wang on 2024/01/11.
//

import AppIntents

struct GaitDetectorWatch: AppIntent {
    static var title: LocalizedStringResource = "GaitDetectorWatch"
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
