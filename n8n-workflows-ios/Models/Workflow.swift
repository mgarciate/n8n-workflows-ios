//
//  Workflow.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 12/9/24.
//

import AppIntents

struct Workflow: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let active: Bool
    let createdAt: String
    let updatedAt: String
}

extension Workflow {
    static let dummyWorkflows = (1...10).map {
        return Workflow(id: "id\($0)", name: "workflow name \($0)", active: true, createdAt: "createdAt", updatedAt: "updatedAt")
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
