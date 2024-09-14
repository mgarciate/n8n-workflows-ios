//
//  iosApp.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 12/9/24.
//

import SwiftUI

@main
struct iosApp: App {
    var body: some Scene {
        WindowGroup {
            MainView(viewModel: MainViewModel())
        }
    }
}
