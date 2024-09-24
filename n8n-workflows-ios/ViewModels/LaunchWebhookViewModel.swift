//
//  LaunchWebhookViewModel.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 24/9/24.
//

import SwiftUI

final class LaunchWebhookViewModel: LaunchWebhookViewModelProtocol {
    var webhook: Webhook
    @Published var webhookAuthenticationType: WebhookAuthType
    @Published var test: Bool = false
    @Published var httpMethod: HTTPMethod = .get
    @Published var jsonText: String = "{}"
    @Published var queryParams: [QueryParam] = []
    
    init(webhook: Webhook) {
        self.webhook = webhook
        webhookAuthenticationType = UserDefaults.standard.decode(WebhookAuthType.self, forKey: "webhook-authentication-type") ?? .noAuth
    }
    
    func send() {
        let params: [String: Any]
        switch httpMethod {
        case .get:
            queryParams.removeAll(where: {
                $0.key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty  ||
                $0.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            })
            params = Dictionary(uniqueKeysWithValues: queryParams.map { ($0.key, $0.value) })
        case .post:
            if !validateJson() { jsonText = "{}" }
            guard let dict = convertJsonTextToDict() else {
                params = [:]
                break
            }
            params = dict
        }
        print(params)
    }
    
    private func convertJsonTextToDict() -> [String: Any]? {
        guard let data = jsonText.data(using: .utf8) else { return nil }
        guard let params = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return nil}
        return params
    }
    
    func validateJson() -> Bool {
        convertJsonTextToDict() != nil
    }
}
