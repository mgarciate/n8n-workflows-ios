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

struct WorkflowNode: Codable, Hashable {
    let name: String
    let type: WorkflowNodeType?
    let webhookId: String?
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
                    !webhookId.isEmpty else { return nil }
            return Webhook(id: webhookId, name: $0.name)
        }
    }
}

extension Workflow {
    static let dummyWorkflows = (0...10).map {
        let node = ($0 % 3 == 0) ? WorkflowNode(name: "Node name \($0)", type: .workflow, webhookId: "webhookId\($0)") : WorkflowNode(name: "Node name \($0)", type: nil, webhookId: nil)
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
