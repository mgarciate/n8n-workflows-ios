//
//  WebhookRequest.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 24/9/24.
//

import Foundation

class WebhookRequest: HTTPClient {
    enum Endpoint {
        case webhook(id: String, isTest: Bool = false)
        
        var path: String {
            switch self {
            case .webhook(let id, let isTest):
                return !isTest ? "/webhook/\(id)" : "/webhook-test/\(id)"
            }
        }
    }
    
    let baseURL: String
    let urlSession: URLSession
    var headers: [String: String] = [:]
    
    init() {
        let url = UserDefaults.standard.string(forKey: "host-url") ?? ""
        baseURL = "\(url)"
        urlSession = URLSession.shared
        
        // Configure headers for Basic Auth or other headers
        let webhookAuthenticationType = UserDefaults.standard.decode(WebhookAuthType.self, forKey: "webhook-authentication-type") ?? .noAuth
        switch webhookAuthenticationType {
        case .basic:
            if let username = UserDefaults.standard.string(forKey: "webhook-authentication-param1"),
               let password = UserDefaults.standard.string(forKey: "webhook-authentication-param2") {
                let loginString = "\(username):\(password)"
                if let loginData = loginString.data(using: .utf8) {
                    let base64LoginString = loginData.base64EncodedString()
                    headers["Authorization"] = "Basic \(base64LoginString)"
                }
            }
        case .header:
            if let key = UserDefaults.standard.string(forKey: "webhook-authentication-param1"),
               let value = UserDefaults.standard.string(forKey: "webhook-authentication-param2") {
                headers[key] = value
            }
        case .jwt, .noAuth:
            break
        }
    }
    
    func get<T: Codable>(endpoint: Endpoint, params: [String: Any] = [:]) async throws -> T {
        print(endpoint.path)
        return try await get(endpoint: endpoint.path, params: params)
    }

    func post<T: Codable>(endpoint: Endpoint, body: [String: Any] = [:], isTest: Bool = false) async throws -> T {
        print(endpoint.path)
        return try await post(endpoint: endpoint.path, body: body)
    }
}
