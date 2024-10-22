//
//  WebhookOptionsProvider.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 10/10/24.
//

import AppIntents

// Define the options provider for the webhook parameter
fileprivate struct WebhookOptionsProvider: DynamicOptionsProvider {
    @ParameterDependency(\LaunchWebhookIntent.$workflow) var workflow
    
    func results() async throws -> [Webhook] {
        return workflow?.workflow.webhooks ?? []
    }
}

struct LaunchWebhookIntent: AppIntent {
    static var title: LocalizedStringResource = "Basic Webhook Launcher"
    static var description: IntentDescription? = "This action enables you to launch a webhook by selecting a workflow and then choosing the specific webhook you wish to trigger. Remember to ensure that the workflow is activated when executing a webhook."
    
    @Parameter(title: "Workflow")
    var workflow: Workflow
    
    @Parameter(title: "Webhook", optionsProvider: WebhookOptionsProvider())
    var webhook: Webhook
    
    static var parameterSummary: some ParameterSummary {
        Summary("Launch webhook from \(\.$workflow)") {
            \.$webhook
        }
    }
    
    func perform() async throws -> some IntentResult {
        if webhook.httpMethod == .post {
            let _: WebhookResponse = try await WebhookRequest().post(endpoint: .webhook(id: webhook.id, isTest: false), body: [:])
        } else {
            let _: WebhookResponse = try await WebhookRequest().get(endpoint: .webhook(id: webhook.id, isTest: false))
        }
        return .result()
    }
}
