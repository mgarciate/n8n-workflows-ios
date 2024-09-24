//
//  MockLaunchWebhookViewModel.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 24/9/24.
//

import SwiftUI

final class MockLaunchWebhookViewModel: LaunchWebhookViewModelProtocol {
    var webhook: Webhook
    @Published var webhookAuthenticationType: WebhookAuthType
    @Published var test: Bool = false
    @Published var httpMethod: HTTPMethod = .get
    @Published var jsonText: String = "{}"
    @Published var queryParams: [QueryParam] = []
    
    init(webhook: Webhook) {
        self.webhook = webhook
        webhookAuthenticationType = .noAuth
    }
    
    func send() {}
    func validateJson() -> Bool {
        true
    }
}
