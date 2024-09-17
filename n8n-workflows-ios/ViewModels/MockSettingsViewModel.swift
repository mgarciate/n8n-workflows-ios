//
//  MockSettingsViewModel.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 17/9/24.
//

import SwiftUI

final class MockSettingsViewModel: SettingsViewModelProtocol {
    @Published var apiKey: String = ""
    var apiKeyBinding: Binding<String> {
        Binding(
            get: { self.apiKey },
            set: { newValue in
                self.apiKey = newValue
            }
        )
    }
}
