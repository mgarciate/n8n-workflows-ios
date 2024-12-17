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

struct ResponseFailed: Codable {
    let code: Int?
    let message: String
    let hint: String?
}

enum ApiError: Error {
    case missingURL
    case badResponse
    case unauthorized
    case parsingError
    case error(details: ResponseFailed)
}

extension ApiError {
    var title: String {
        switch self {
        case .missingURL:
            return "URL error"
        case .badResponse:
            return "Bad response"
        case .unauthorized:
            return "Unauthorized"
        case .parsingError:
            return "Parsing error"
        case .error(let error):
            guard let errorCode = error.code else { return "Error" }
            return "Code \(errorCode)"
        }
    }
    
    var message: String {
        switch self {
        case .missingURL:
            return "The URL the application is trying to access is incorrect."
        case .badResponse:
            return "The server cannot find the requested resource."
        case .unauthorized:
            return "The host and credentials are not configured correctly. You can check and set them up using the button ⚙️ in the top right corner  ⤴."
        case .parsingError:
            return "Error parsing the server response: the data format is invalid or unexpected."
        case .error(let error):
            var message = error.message
            if let hint = error.hint {
                message += "\n\(hint)"
            }
            return message
        }
    }
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
        MyLogger.shared.info("HTTPClient GET: \(endpoint, privacy: .public) \(params, privacy: .public)")
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
        MyLogger.shared.info("HTTPClient URL: \(urlRequest.url?.absoluteString ?? "NO URL", privacy: .public)")
        var (data, response) = try await urlSession.data(for: urlRequest)
        let stringData: String = String(data: data, encoding: .utf8) ?? "NO DATA"
        MyLogger.shared.info("HTTPClient DATA: \(stringData, privacy: .public)")
        try validate(data: data, response: response)
        do {
            let element = try JSONDecoder().decode(T.self, from: data)
            return element
        } catch {
            MyLogger.shared.error("HTTPClient ParsingError: \(error, privacy: .public)")
            throw ApiError.parsingError
        }
    }
    
    func post<T: Decodable>(endpoint: String, body: [String: Any]) async throws -> T {
        MyLogger.shared.info("HTTPClient POST: \(endpoint, privacy: .public) \(body, privacy: .public)")
        guard let url = URL(string: baseURL + endpoint) else { throw ApiError.missingURL }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        headers.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        MyLogger.shared.info("HTTPClient URL: \(urlRequest.url?.absoluteString ?? "NO URL", privacy: .public)")
        let (data, response) = try await urlSession.data(for: urlRequest)
        let stringData: String = String(data: data, encoding: .utf8) ?? "NO DATA"
        MyLogger.shared.info("HTTPClient DATA: \(stringData, privacy: .public)")
        try validate(data: data, response: response)
        do {
            let element = try JSONDecoder().decode(T.self, from: data)
            return element
        } catch {
            MyLogger.shared.error("HTTPClient ParsingError: \(error, privacy: .public)")
            throw ApiError.parsingError
        }
    }
    
    private func validate(data: Data, response: URLResponse) throws {
#if DEBUG
        print("Data: \(String(data: data, encoding: .utf8))")
#endif
        let stringData: String = String(data: data, encoding: .utf8) ?? "NO DATA"
        MyLogger.shared.info("HTTPClient validate: \(stringData, privacy: .public)")
        guard let response = response as? HTTPURLResponse else { throw ApiError.badResponse }
        guard response.statusCode == 200 else {
            switch response.statusCode {
            case 401:
                MyLogger.shared.warning("HTTPClient validate 401")
                throw ApiError.unauthorized
            default: break
            }
            guard let responseFailed = try? JSONDecoder().decode(ResponseFailed.self, from: data) else { throw ApiError.badResponse }
            throw ApiError.error(details: responseFailed)
        }
        MyLogger.shared.info("HTTPClient validate 200")
    }
}

