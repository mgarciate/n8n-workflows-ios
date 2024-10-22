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
    @Published var httpMethod: HTTPMethod
    @Published var jsonText: String = "{}"
    @Published var queryParams: [QueryParam] = []
    @Published var isAlertPresented: Bool = false
    @Published var apiResult: Result<WebhookResponse, ApiError>?
    
    init(webhook: Webhook) {
        self.webhook = webhook
        webhookAuthenticationType = UserDefaultsHelper.shared.webhookAuthType ?? .noAuth
        httpMethod = webhook.httpMethod == .post ? .post : .get
    }
    
    func send() async {
        let result: Result<WebhookResponse, ApiError>
        switch httpMethod {
        case .get:
            await MainActor.run {
                queryParams.removeAll(where: {
                    $0.key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty  ||
                    $0.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                })
            }
            let params = Dictionary(uniqueKeysWithValues: queryParams.map { ($0.key, $0.value) })
            do {
                let response: WebhookResponse = try await WebhookRequest().get(endpoint: .webhook(id: webhook.id, isTest: test), params: params)
                result = .success(response)
            } catch {
#if DEBUG
                print("Error", error)
#endif
                guard let error = error as? ApiError else { return }
                result = .failure(error)
            }
        case .post:
            await MainActor.run {
                if !validateJson() { jsonText = "{}" }
            }
            let body = convertJsonTextToDict() ?? [:]
            do {
                let response: WebhookResponse = try await WebhookRequest().post(endpoint: .webhook(id: webhook.id, isTest: test), body: body)
                result = .success(response)
            } catch {
#if DEBUG
                print("Error", error)
#endif
                result = .failure(error as? ApiError ?? .error(details: ResponseFailed(code: nil, message: error.localizedDescription, hint: nil)))
            }
        }
        await MainActor.run {
            isAlertPresented = true
            apiResult = result
        }
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
