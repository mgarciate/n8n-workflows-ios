//
//  Workflow.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 12/9/24.
//

import AppIntents

struct Webhook: Codable, Identifiable {
    let id: String
    let name: String
    let path: String
}

enum WorkflowNodeType: String {
    case workflow = "n8n-nodes-base.webhook"
    case unknown
}

extension WorkflowNodeType: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let decodedValues = try container.decode(String.self)
        switch decodedValues {
        case WorkflowNodeType.workflow.rawValue:
            self = .workflow
        default:
            self = .unknown
        }
    }
}

struct WorkflowNodeParameters: Codable, Hashable {
    let path: String?
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
            guard $0.type == .workflow,
                  let webhookId = $0.webhookId,
                  let path = $0.parameters?.path,
                  !path.isEmpty else { return nil }
            return Webhook(id: webhookId, name: $0.name, path: path)
        }
    }
}

extension Workflow {
    static let dummyWorkflows = (0...10).map {
        let node = ($0 % 3 == 0) ? WorkflowNode(name: "Node name \($0)", type: .workflow, webhookId: "webhookId\($0)", parameters: WorkflowNodeParameters(path: "Node path \($0)")) : WorkflowNode(name: "Node name \($0)", type: nil, webhookId: nil, parameters: nil)
        return Workflow(id: "id\($0)", name: "workflow name \($0)", active: true, createdAt: "createdAt", updatedAt: "updatedAt", nodes: [node])
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
        try await NetworkService<DataResponse<Workflow>>().get(endpoint: "workflows").data
    }
    
    func suggestedEntities() async throws -> [Workflow] {
        try await NetworkService<DataResponse<Workflow>>().get(endpoint: "workflows").data
    }
}
