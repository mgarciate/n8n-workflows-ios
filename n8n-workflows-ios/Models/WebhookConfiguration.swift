//
//  WebhookConfiguration.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 10/10/24.
//

import Foundation
import SwiftData
import AppIntents

@Model
final class WebhookConfiguration: Identifiable {
    static let defaultName = "New profile"
    
    var id = UUID().uuidString
    var webhookId: String?
    var name: String = WebhookConfiguration.defaultName
    var webhookAuthType: String = WebhookAuthType.noAuth.rawValue
    var webhookAuthParam1: String = ""
    var webhookAuthParam2: String = ""
    var httpMethod: String = HTTPMethod.get.rawValue
    var jsonText: String = "{}"
    var queryParams: [String: String] = [:]
    
    init(id: String = UUID().uuidString,
         webhookId: String,
         name: String,
         webhookAuthType: WebhookAuthType = .noAuth,
         webhookAuthParam1: String = "",
         webhookAuthParam2: String = "",
         httpMethod: HTTPMethod = HTTPMethod.get,
         jsonText: String = "{}",
         queryParams: [String: String] = [:]) {
        self.id = id
        self.webhookId = webhookId
        self.name = name
        self.webhookAuthType = webhookAuthType.rawValue
        self.webhookAuthParam1 = webhookAuthParam1
        self.webhookAuthParam2 = webhookAuthParam2
        self.httpMethod = httpMethod.rawValue
        self.jsonText = jsonText
        self.queryParams = queryParams
    }
}

extension WebhookConfiguration {
    var httpMethodOrDefault: HTTPMethod {
        get {
            HTTPMethod(rawValue: httpMethod) ?? .get
        }
    }
    
    static func buildDefaultConfiguration(webhookId: String, index: Int? = nil) -> WebhookConfiguration {
        WebhookConfiguration(
            webhookId: webhookId,
            name: index.map { "\(WebhookConfiguration.defaultName) (\($0))" } ?? WebhookConfiguration.defaultName,
            httpMethod: HTTPMethod.get
        )
    }
}

struct WebhookConfigurationEntity: AppEntity, Identifiable {
    var id: String
    var title: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: LocalizedStringResource(stringLiteral: title))
    }

    static var defaultQuery = WebhookConfigurationQuery()

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Webhook Configuration"

    init(id: String, title: String) {
        self.id = id
        self.title = title
    }

    init(webhookConfiguration: WebhookConfiguration) {
        self.id = webhookConfiguration.id
        self.title = webhookConfiguration.name
    }
}

struct WebhookConfigurationQuery: EntityQuery {
    
    func entities(for identifiers: [WebhookConfigurationEntity.ID]) async throws -> [WebhookConfigurationEntity] {
        // Fetch Items from your SwiftData store based on identifiers and convert them to ItemEntity
        var entities: [WebhookConfigurationEntity] = []

        // Replace the following with your actual data fetching logic
        let items = await fetchItemsByIds(identifiers)

        for item in items {
            entities.append(WebhookConfigurationEntity(webhookConfiguration: item))
        }

        return entities
    }

    // Dummy fetch function - replace with actual data fetching logic
    func fetchItemsByIds(_ ids: [String]) async -> [WebhookConfiguration] {
        // Fetch items from your data store
        // For example:
        // return await Item.fetch(ids: ids)

        // Example items for demonstration purposes
        return ids.map { WebhookConfiguration(webhookId: "nil", name: "Example Item with ID: \($0)") }
    }
}
