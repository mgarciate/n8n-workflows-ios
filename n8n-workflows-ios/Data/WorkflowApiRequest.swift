//
//  WorkflowApiRequest.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 24/9/24.
//

import Foundation

class WorkflowApiRequest: HTTPClient {
    enum Endpoint {
        case workflows
        case executions
        case projects
        case workflowAction(id: String, actionType: WorkflowActionType)
        case tags
        
        var path: String {
            switch self {
            case .workflows: "/workflows"
            case .executions: "/executions"
            case .projects: "/projects"
            case .workflowAction(let id, let actionType): "/workflows/\(id)/\(actionType)"
            case .tags: "/tags"
            }
        }
    }

    let baseURL: String
    let urlSession: URLSession
    var headers: [String: String] = [:]
    private let headerFieldName = "X-N8N-API-KEY"

    init() throws {
        let url = UserDefaultsHelper.shared.hostUrl ?? ""
        baseURL = "\(url)/api/v1"
        urlSession = URLSession.shared

        guard let apiKey = KeychainHelper.shared.retrieveApiKey(
            service: KeychainHelper.service,
            account: KeychainHelper.account
        ), !apiKey.isEmpty else {
            throw ApiError.unauthorized
        }
        headers[headerFieldName] = apiKey
    }

    func get<T: Codable>(endpoint: Endpoint, params: [String: Any] = [:]) async throws -> T {
        MyLogger.shared.info("WorkflowApiRequest GET: \(endpoint.path, privacy: .public) \(params, privacy: .public)")
        var params = params
        params["limit"] = 250
        return try await get(endpoint: endpoint.path, params: params)
    }

    func post<T: Codable>(endpoint: Endpoint, body: [String: Any] = [:]) async throws -> T {
        MyLogger.shared.info("WorkflowApiRequest POST: \(endpoint.path, privacy: .public) \(body, privacy: .public)")
        return try await post(endpoint: endpoint.path, body: body)
    }
}

