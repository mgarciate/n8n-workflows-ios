//
//  MockSettingsViewModel.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 17/9/24.
//

import SwiftUI

final class MockSettingsViewModel: SettingsViewModelProtocol {
    @Published var selfhostIsOn: Bool = false
    @Published var url: String = ""
    @Published var apiKey: String = ""
    @Published var webhookAuthenticationType: WebhookAuthType = .noAuth
    @Published var webhookAuthenticationParam1: String = ""
    @Published var webhookAuthenticationParam2: String = ""
    
    func save() {}
}
