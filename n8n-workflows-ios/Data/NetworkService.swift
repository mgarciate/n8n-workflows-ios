//
//  NetworkService.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 12/9/24.
//

import Foundation

enum WorkflowActionType {
    case activate, deactivate
}

class NetworkService<T> where T: Codable {
    enum ApiError: Error {
        case missingURL
        case badResponse
        case unauthorized
        case parsingError
    }
    private let headerFieldName = "X-N8N-API-KEY"
    private let urlSession: URLSession
    private let baseURL: String
    private var authHeader: (key: String, value: String)?
    
    init() {
        urlSession = URLSession.shared
        let url = UserDefaults.standard.string(forKey: "host-url") ?? ""
        baseURL = "\(url)/api/v1"
        let webhookAuthenticationType = UserDefaults.standard.decode(WebhookAuthType.self, forKey: "webhook-authentication-type") ?? .noAuth
        switch webhookAuthenticationType {
        case .basic:
            guard let username = UserDefaults.standard.string(forKey: "webhook-authentication-param1"),
                  let password = UserDefaults.standard.string(forKey: "webhook-authentication-param2") else { break }
            let loginString = String(format: "%@:%@", username, password)
            guard let loginData = loginString.data(using: String.Encoding.utf8) else { break }
            let base64LoginString = loginData.base64EncodedString()
            authHeader = ("Authorization", "Basic \(base64LoginString)")
        case .header:
            guard let key = UserDefaults.standard.string(forKey: "webhook-authentication-param1"),
                  let value = UserDefaults.standard.string(forKey: "webhook-authentication-param2") else { break }
            authHeader = (key, value)
        case .jwt, .noAuth: break
        }
    }
    
    func get(endpoint: String, params: [String: Any] = [:]) async throws -> T {
        guard var urlComponents = URLComponents(string: [baseURL, endpoint].joined(separator: "/")) else {
            throw ApiError.missingURL
        }
        urlComponents.queryItems = params.map { (key, value) in
            URLQueryItem(name: key, value: "\(value)")
        }
        guard let url = urlComponents.url else {
            throw ApiError.missingURL
        }
        guard let apiKey = KeychainHelper.shared.retrieveApiKey(service: KeychainHelper.service, account: KeychainHelper.account),
                !apiKey.isEmpty else { throw ApiError.unauthorized }
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue(apiKey, forHTTPHeaderField: headerFieldName)
        let (data, response) = try await urlSession.data(for: urlRequest)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw ApiError.badResponse }
        do{
            let _ = try JSONDecoder().decode(T.self, from: data)
        }catch{
            print(error)
        }
        guard let element = try? JSONDecoder().decode(T.self, from: data) else { throw ApiError.parsingError }
        return element
    }
    
    func post(endpoint: String, body: [String: Any]) async throws -> T {
        guard let url = URL(string: [baseURL, endpoint].joined(separator: "/")) else { throw ApiError.missingURL }
        guard let apiKey = KeychainHelper.shared.retrieveApiKey(service: KeychainHelper.service, account: KeychainHelper.account),
                !apiKey.isEmpty else { throw ApiError.unauthorized }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        urlRequest.setValue(apiKey, forHTTPHeaderField: headerFieldName)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await urlSession.data(for: urlRequest)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw ApiError.badResponse }
        guard let element = try? JSONDecoder().decode(T.self, from: data) else { throw ApiError.parsingError }
        return element
    }
}
