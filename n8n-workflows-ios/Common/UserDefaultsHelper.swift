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
}
