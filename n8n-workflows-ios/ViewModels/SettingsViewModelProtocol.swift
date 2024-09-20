//
//  SettingsViewModelProtocol.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 17/9/24.
//


import SwiftUI

protocol SettingsViewModelProtocol: ObservableObject {
    var selfhostIsOn: Bool { get set }
    var url: String { get set }
    var apiKey: String { get set }
    var webhookAuthenticationType: WebhookAuthType { get set }
    var webhookAuthenticationParam1: String { get set }
    var webhookAuthenticationParam2: String { get set }
    
    func save()
}
