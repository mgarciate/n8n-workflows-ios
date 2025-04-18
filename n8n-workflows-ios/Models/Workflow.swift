//
//  Workflow.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 12/9/24.
//

import AppIntents

enum WorkflowNodeType: String {
    case webhook = "n8n-nodes-base.webhook"
    case chat = "@n8n/n8n-nodes-langchain.chatTrigger"
    case unknown
}

extension WorkflowNodeType: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let decodedValues = try container.decode(String.self)
        switch decodedValues {
        case WorkflowNodeType.webhook.rawValue:
            self = .webhook
        case WorkflowNodeType.chat.rawValue:
            self = .chat
        default:
            self = .unknown
        }
    }
}

struct WorkflowNodeParameters: Codable, Hashable {
    let path: String?
    let httpMethod: HTTPMethod?
    let isPublic: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case path
        case httpMethod
        case isPublic = "public"
    }
}

struct WorkflowNode: Codable, Hashable {
    let name: String
    let type: WorkflowNodeType?
    let webhookId: String?
    let parameters: WorkflowNodeParameters?
}

struct Workflow: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let active: Bool
    let createdAt: String
    let updatedAt: String
    let nodes: [WorkflowNode]
}

extension Workflow {
    var webhooks: [Webhook] {
        nodes.compactMap {
            guard $0.type == .webhook,
                  let webhookId = $0.webhookId,
                  let path = $0.parameters?.path,
                  !path.isEmpty else { return nil }
            return Webhook(id: webhookId, name: $0.name, path: path, httpMethod: $0.parameters?.httpMethod)
        }
    }
}

extension Workflow {
    static private func format(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.string(from: date)
    }
    static var dummyWorkflows: [Workflow] {
        var date = "2024-09-20T21:11:58.094Z".date ?? Date.now
        return (0...10).map {
            let createdDate = date
            let updatedDate = date.addingTimeInterval(60) // add 1 minute
            date.addTimeInterval(3600) // add 1 hour
            let node = ($0 % 3 == 0) ? WorkflowNode(name: "Node name \($0)", type: .webhook, webhookId: "webhookId\($0)", parameters: WorkflowNodeParameters(path: "Node path \($0)", httpMethod: .get, isPublic: true)) : WorkflowNode(name: "Node name \($0)", type: nil, webhookId: nil, parameters: nil)
            return Workflow(id: "id\($0)", name: "workflow name \($0)", active: true, createdAt: format(date: createdDate), updatedAt: format(date: updatedDate), nodes: [node])
        }
    }
}

extension Workflow: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation  = "Workflow"
    var displayRepresentation: DisplayRepresentation {
        .init(title: LocalizedStringResource(stringLiteral: name))
    }
    static var defaultQuery = WorkflowQuery()
}

struct WorkflowQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [Workflow] {
        let response: DataResponse<Workflow> = try await WorkflowApiRequest().get(endpoint: .workflows)
        return response.data
    }
    
    func suggestedEntities() async throws -> [Workflow] {
        let response: DataResponse<Workflow> = try await WorkflowApiRequest().get(endpoint: .workflows)
        return response.data
    }
}
