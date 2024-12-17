//
//  iosApp.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 12/9/24.
//

import SwiftUI
import OSLog

let logger = Logger(subsystem: "com.mgarciate.n8n-workflows", category: "debugging")

@main
struct iosApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}
