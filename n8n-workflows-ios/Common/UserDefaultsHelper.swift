//
//  UserDefaultsHelper.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 8/10/24.
//


import Foundation

class UserDefaultsHelper {
    static let shared = UserDefaultsHelper()
    private let defaults = UserDefaults.standard
    
    // MARK: - Computed Properties
    var hostUrl: String? {
        get { defaults.string(forKey: "host-url") }
        set { defaults.set(newValue, forKey: "host-url") }
    }
    
    var webhookAuthType: WebhookAuthType? {
        get { defaults.decode(WebhookAuthType.self, forKey: "webhook-authentication-type") }
        set { defaults.encode(newValue, forKey: "webhook-authentication-type") }
    }
    
    var webhookAuthParam1: String? {
        get { defaults.string(forKey: "webhook-authentication-param1") }
        set { defaults.set(newValue, forKey: "webhook-authentication-param1") }
    }
    
    var webhookAuthParam2: String? {
        get { defaults.string(forKey: "webhook-authentication-param2") }
        set { defaults.set(newValue, forKey: "webhook-authentication-param2") }
    }
    
    var onboardingDisplayed: Bool {
        get { defaults.bool(forKey: "onboarding-displayed") }
        set { defaults.set(newValue, forKey: "onboarding-displayed") }
    }
    
    var selfHost: Bool {
        get { defaults.bool(forKey: "selfhost") }
        set { defaults.set(newValue, forKey: "selfhost") }
    }
    
    func clearAll() -> Bool {
        guard let appDomain = Bundle.main.bundleIdentifier else { return false }
        defaults.removePersistentDomain(forName: appDomain)
        defaults.synchronize()
        return true
    }
}

extension UserDefaultsHelper {
    func saveUserConfig(_ userConfig: UserConfiguration) {
        hostUrl = userConfig.hostUrl
        selfHost = userConfig.selfHost ?? false
        webhookAuthType = userConfig.webhookAuthType
        webhookAuthParam1 = userConfig.webhookAuthParam1
        webhookAuthParam2 = userConfig.webhookAuthParam2
    }
    
    var userConfig: UserConfiguration {
        get {
            UserConfiguration(
                selfHost: selfHost,
                hostUrl: hostUrl,
                webhookAuthType: webhookAuthType,
                webhookAuthParam1: webhookAuthParam1,
                webhookAuthParam2: webhookAuthParam2
            )
        }
    }
}
