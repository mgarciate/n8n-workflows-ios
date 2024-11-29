//
//  LaunchAdvancedWebhookIntent.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 22/10/24.
//

import AppIntents
import SwiftData
import SwiftUI

// Define the options provider for the webhook parameter
fileprivate struct WebhookOptionsProvider: DynamicOptionsProvider {
    @ParameterDependency(\LaunchAdvancedWebhookIntent.$workflow) var workflow
    
    func results() async throws -> [Webhook] {
        return workflow?.workflow.webhooks ?? []
    }
}


fileprivate struct ConfigurationOptionsProvider: DynamicOptionsProvider {
    @ParameterDependency(\LaunchAdvancedWebhookIntent.$webhook) var webhook
    
    func results() async throws -> [WebhookConfigurationEntity] {
        guard let webhookId = webhook?.webhook.id else { return [] }
        guard let modelContainer = try? ModelContainer(for: WebhookConfiguration.self) else {
            throw NSError(domain: "FetchItemsError", code: 1, userInfo: [NSLocalizedDescriptionKey: "The data container could not be obtained."])
        }
        
        let context = await modelContainer.mainContext
        let fetchDescriptor = FetchDescriptor<WebhookConfiguration>(
            predicate: #Predicate {
                $0.webhookId == webhookId
            },
            sortBy: [SortDescriptor(\.name)]
        )
        let items = try context.fetch(fetchDescriptor)
        print(items.map { $0.name }.joined(separator: ","))
        
        return items.map { WebhookConfigurationEntity(webhookConfiguration: $0) }
    }
}

struct LaunchAdvancedWebhookIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Advanced Webhook Launcher"
    static var description: IntentDescription? = "This action enables you to launch a webhook by selecting a workflow and then choosing the specific webhook you wish to trigger. Remember to ensure that the workflow is activated when executing a webhook."
    
    @Parameter(title: "Workflow")
    var workflow: Workflow
    
    @Parameter(title: "Webhook", optionsProvider: WebhookOptionsProvider())
    var webhook: Webhook
    
    @Parameter(title: "WebhookConfigurationEntity", optionsProvider: ConfigurationOptionsProvider())
    var configuration: WebhookConfigurationEntity
    
//    static var parameterSummary: some ParameterSummary {
//        Summary("Launch webhook from \(\.$workflow)") {
//            \.$configuration
//        }
//    }
    
    func perform() async throws -> some IntentResult {
//        if webhook.httpMethod == .post {
//            let _: WebhookResponse = try await WebhookRequest().post(endpoint: .webhook(id: webhook.id, isTest: false), body: [:])
//        } else {
//            let _: WebhookResponse = try await WebhookRequest().get(endpoint: .webhook(id: webhook.id, isTest: false))
//        }
        return .result()
    }
}
