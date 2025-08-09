//
//  SettingsViewModel.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 18/9/24.
//

import SwiftUI

final class SettingsViewModel: SettingsViewModelProtocol {
    @Published var selfhostIsOn: Bool
    @Published var url: String
    @Published var apiKey: String
    @Published var webhookAuthenticationType: WebhookAuthType
    @Published var webhookAuthenticationParam1: String
    @Published var webhookAuthenticationParam2: String
    
    init() {
        selfhostIsOn = UserDefaultsHelper.shared.selfHost
        url = UserDefaultsHelper.shared.hostUrl ?? ""
        webhookAuthenticationType = UserDefaultsHelper.shared.webhookAuthType ?? .noAuth
        webhookAuthenticationParam1 = UserDefaultsHelper.shared.webhookAuthParam1 ?? ""
        webhookAuthenticationParam2 = UserDefaultsHelper.shared.webhookAuthParam2 ?? ""
        
        apiKey = KeychainHelper.shared.retrieveApiKey(
            service: KeychainHelper.service,
            account: KeychainHelper.account
        ) ?? ""
    }
    
    private func resetWebhookAuth() {
        webhookAuthenticationType = .noAuth
        webhookAuthenticationParam1 = ""
        webhookAuthenticationParam2 = ""
    }
    
    private func validateWebhookAuth() {
        switch webhookAuthenticationType {
        case .basic, .header, .jwt:
            guard !webhookAuthenticationParam1.isEmpty, !webhookAuthenticationParam2.isEmpty else {
                resetWebhookAuth()
                break
            }
        case .noAuth:
            resetWebhookAuth()
        }
    }
    
    func save() {
        validateWebhookAuth()
        UserDefaultsHelper.shared.selfHost = selfhostIsOn
        UserDefaultsHelper.shared.hostUrl = url
        UserDefaultsHelper.shared.webhookAuthType = webhookAuthenticationType
        UserDefaultsHelper.shared.webhookAuthParam1 = webhookAuthenticationParam1
        UserDefaultsHelper.shared.webhookAuthParam2 = webhookAuthenticationParam2
        _ = KeychainHelper.shared.saveApiKey(
            apiKey,
            service: KeychainHelper.service,
            account: KeychainHelper.account
        )
        Task {
            do {
                try await UserConfigurationManager.shared.updateSettings(UserConfiguration(
                    selfHost: selfhostIsOn,
                    hostUrl: url,
                    webhookAuthType: webhookAuthenticationType,
                    webhookAuthParam1: webhookAuthenticationParam1,
                    webhookAuthParam2: webhookAuthenticationParam2
                ))
#if DEBUG
                print("Configuration updated successfully.")
#endif
            } catch {
#if DEBUG
                print("Error updating CloudKit configuration: \(error.localizedDescription)")
#endif
            }
        }
    }
}
