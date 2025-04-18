//
//  Webhook.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 23/9/24.
//


import AppIntents

struct Webhook: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let path: String
    let httpMethod: HTTPMethod?
}

struct ChatTrigger: Identifiable {
    let id: String
}

extension Webhook {
    static var dummyWebhook: Webhook {
        Webhook(id: "webhookId", name: "webhookName", path: "webhookPath", httpMethod: .get)
    }
}

extension Webhook: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation  = "Webhook"
    
    var displayRepresentation: DisplayRepresentation {
        .init(title: "\(name)", subtitle: "\(path)")
    }
    
    static var defaultQuery = WebhookQuery()
}

struct WebhookQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [Webhook] {
        guard let id = identifiers.first else { return  [] }
        let response: DataResponse<Workflow> = try await WorkflowApiRequest().get(endpoint: .workflows)
        guard let webhook = response.data.flatMap({ $0.webhooks }).first(where: { $0.id == id }) else { return [] }
        return [webhook]
    }
    
    func suggestedEntities() async throws -> [Webhook] {
        return []
    }
}
