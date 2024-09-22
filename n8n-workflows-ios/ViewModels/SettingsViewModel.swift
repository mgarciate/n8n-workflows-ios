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
        selfhostIsOn = UserDefaults.standard.bool(forKey: "selfhost")
        url = UserDefaults.standard.string(forKey: "host-url") ?? ""
        webhookAuthenticationType = UserDefaults.standard.decode(WebhookAuthType.self, forKey: "webhook-authentication-type") ?? .noAuth
        webhookAuthenticationParam1 = UserDefaults.standard.string(forKey: "webhook-authentication-param1") ?? ""
        webhookAuthenticationParam2 = UserDefaults.standard.string(forKey: "webhook-authentication-param2") ?? ""
        
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
        case .basic, .header:
            guard !webhookAuthenticationParam1.isEmpty, !webhookAuthenticationParam2.isEmpty else {
                resetWebhookAuth()
                break
            }
        case .jwt, .noAuth:
            resetWebhookAuth()
        }
    }
    
    func save() {
        validateWebhookAuth()
        UserDefaults.standard.set(selfhostIsOn, forKey: "selfhost")
        UserDefaults.standard.set(url, forKey: "host-url")
        UserDefaults.standard.encode(webhookAuthenticationType, forKey: "webhook-authentication-type")
        UserDefaults.standard.set(webhookAuthenticationParam1, forKey: "webhook-authentication-param1")
        UserDefaults.standard.set(webhookAuthenticationParam2, forKey: "webhook-authentication-param2")
        _ = KeychainHelper.shared.saveApiKey(
            apiKey,
            service: KeychainHelper.service,
            account: KeychainHelper.account
        )
    }
}
