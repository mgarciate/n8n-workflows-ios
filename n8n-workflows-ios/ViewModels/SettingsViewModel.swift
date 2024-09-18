//
//  SettingsViewModel.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 18/9/24.
//

import SwiftUI

final class SettingsViewModel: SettingsViewModelProtocol {
    @Published var apiKey: String = ""
    var apiKeyBinding: Binding<String> {
        Binding(
            get: { self.apiKey },
            set: { newValue in
                self.apiKey = newValue
                self.saveApiKey()
            }
        )
    }
    
    init() {
        apiKey = KeychainHelper.shared.retrieveApiKey(
            service: KeychainHelper.service,
            account: KeychainHelper.account
        ) ?? ""
    }
    
    private func saveApiKey() {
        _ = KeychainHelper.shared.saveApiKey(
            apiKey,
            service: KeychainHelper.service,
            account: KeychainHelper.account
        )
    }
}
