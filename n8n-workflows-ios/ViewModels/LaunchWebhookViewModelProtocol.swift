//
//  LaunchWebhookViewModelProtocol.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 24/9/24.
//

import SwiftUI

protocol LaunchWebhookViewModelProtocol: ObservableObject {
    var webhook: Webhook { get }
    var webhookAuthenticationType: WebhookAuthType { get set }
    var test: Bool { get set }
    var httpMethod: HTTPMethod { get set }
    var jsonText: String { get set }
    var queryParams: [QueryParam] { get set }
    var isAlertPresented: Bool { get set }
    var apiResult: Result<WebhookResponse, ApiError>? { get set }
    
    func send() async
    func validateJson() -> Bool
}
