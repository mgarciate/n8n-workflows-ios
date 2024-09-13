//
//  Workflow.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 12/9/24.
//

struct Workflow: Codable, Identifiable {
    let id: String
    let name: String
    let active: Bool
}

extension Workflow {
    static let dummyWorkflows = (1...10).map {
        return Workflow(id: "id\($0)", name: "workflow name \($0)", active: true)
    }
}
