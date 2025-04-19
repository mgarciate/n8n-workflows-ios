//
//  WebhookRequest.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 24/9/24.
//

import Foundation

class WebhookRequest: HTTPClient {
    enum Endpoint {
        case webhook(path: String, isTest: Bool = false)
        
        var path: String {
            switch self {
            case .webhook(let path, let isTest):
                return !isTest ? "/webhook/\(path)" : "/webhook-test/\(path)"
            }
        }
    }
    
    let baseURL: String
    let urlSession: URLSession
    var headers: [String: String] = [:]
    
    init() {
        let url = UserDefaultsHelper.shared.hostUrl ?? ""
        baseURL = "\(url)"
        urlSession = URLSession.shared
        
        // Configure headers for Basic Auth or other headers
        let webhookAuthenticationType = UserDefaultsHelper.shared.webhookAuthType ?? .noAuth
        switch webhookAuthenticationType {
        case .basic:
            if let username = UserDefaultsHelper.shared.webhookAuthParam1,
               let password = UserDefaultsHelper.shared.webhookAuthParam2 {
                let loginString = "\(username):\(password)"
                if let loginData = loginString.data(using: .utf8) {
                    let base64LoginString = loginData.base64EncodedString()
                    headers["Authorization"] = "Basic \(base64LoginString)"
                }
            }
        case .header:
            if let key = UserDefaultsHelper.shared.webhookAuthParam1,
               let value = UserDefaultsHelper.shared.webhookAuthParam2 {
                headers[key] = value
            }
        case .jwt, .noAuth:
            break
        }
    }
    
    func get<T: Codable>(endpoint: Endpoint, params: [String: Any] = [:]) async throws -> T {
        try await get(endpoint: endpoint.path, params: params)
    }

    func post<T: Codable>(endpoint: Endpoint, body: [String: Any] = [:], isTest: Bool = false) async throws -> T {
        try await post(endpoint: endpoint.path, body: body)
    }
}
