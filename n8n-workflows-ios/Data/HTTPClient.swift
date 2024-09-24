//
//  HTTPClient.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 12/9/24.
//

import Foundation

enum WorkflowActionType {
    case activate, deactivate
}

enum HTTPMethod: String, Codable, CaseIterable {
    case get = "GET"
    case post = "POST"
}

enum ApiError: Error {
    case missingURL
    case badResponse
    case unauthorized
    case parsingError
}

protocol HTTPClient {
    var baseURL: String { get }
    var urlSession: URLSession { get }
    var headers: [String: String] { get }
    
    func get<T: Decodable>(endpoint: String, params: [String: Any]) async throws -> T
    func post<T: Decodable>(endpoint: String, body: [String: Any]) async throws -> T
}

extension HTTPClient {
    func get<T: Decodable>(endpoint: String, params: [String: Any] = [:]) async throws -> T {
        guard var urlComponents = URLComponents(string: baseURL + endpoint) else {
            throw ApiError.missingURL
        }
        urlComponents.queryItems = params.map { (key, value) in
            URLQueryItem(name: key, value: "\(value)")
        }
        guard let url = urlComponents.url else {
            throw ApiError.missingURL
        }
        var urlRequest = URLRequest(url: url)
        headers.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        let (data, response) = try await urlSession.data(for: urlRequest)
#if DEBUG
        print("Data: \(String(data: data, encoding: .utf8))")
#endif
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw ApiError.badResponse }
        do {
            let element = try JSONDecoder().decode(T.self, from: data)
            return element
        } catch {
            throw ApiError.parsingError
        }
    }
    
    func post<T: Decodable>(endpoint: String, body: [String: Any]) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else { throw ApiError.missingURL }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        headers.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try await urlSession.data(for: urlRequest)
#if DEBUG
        print("Data: \(String(data: data, encoding: .utf8))")
#endif
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw ApiError.badResponse }
        do {
            let element = try JSONDecoder().decode(T.self, from: data)
            return element
        } catch {
            throw ApiError.parsingError
        }
    }
}

