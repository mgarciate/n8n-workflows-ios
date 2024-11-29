//
//  MockLaunchWebhookViewModel.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 24/9/24.
//

import SwiftUI

final class MockLaunchWebhookViewModel: LaunchWebhookViewModelProtocol {
    var webhook: Webhook
    @Published var test: Bool = false
    @Published var queryParams: [QueryParam] = []
    @Published var isAlertPresented: Bool = false
    @Published var apiResult: Result<WebhookResponse, ApiError>?
    
    init(webhook: Webhook) {
        self.webhook = webhook
    }
    
    func send(with configuration: WebhookConfiguration) {}
    func validateJson(_ jsonText: String) -> Bool {
        true
    }
}
