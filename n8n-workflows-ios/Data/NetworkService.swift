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
    private let urlSession: URLSession
    private let baseURL: String
    
    init() {
        urlSession = URLSession.shared
        baseURL = "http://192.168.0.104:5678/api/v1"
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
        urlRequest.addValue(apiKey, forHTTPHeaderField: "X-N8N-API-KEY")
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
        urlRequest.addValue(apiKey, forHTTPHeaderField: "X-N8N-API-KEY")
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await urlSession.data(for: urlRequest)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw ApiError.badResponse }
        guard let element = try? JSONDecoder().decode(T.self, from: data) else { throw ApiError.parsingError }
        return element
    }
}
