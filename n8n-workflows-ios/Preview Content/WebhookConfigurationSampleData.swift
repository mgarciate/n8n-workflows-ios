//
//  WebhookConfigurationSampleData.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 10/10/24.
//

import SwiftUI
import SwiftData

struct WebhookConfigurationSampleData: PreviewModifier {
    
    static func makeSharedContext() async throws -> ModelContainer {
        let schema = Schema([WebhookConfiguration.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        
        let webhookConfiguration1 = WebhookConfiguration(
            webhookId: "webhookId1",
            name: "configuration1"
        )
        let webhookConfiguration2 = WebhookConfiguration(
            webhookId: "webhookId1",
            name: "configuration2",
            webhookAuthType: .basic,
            webhookAuthParam1: "basic1",
            webhookAuthParam2: "basic2",
            queryParams: ["key": "mykey", "value": "myValue"]
        )
        let webhookConfiguration3 = WebhookConfiguration(
            webhookId: "webhookId1",
            name: "configuration3",
            webhookAuthType: .basic,
            webhookAuthParam1: "basic1",
            webhookAuthParam2: "basic2",
            httpMethod: HTTPMethod.post,
            jsonText: "{\"key\": \"value\"}"
        )
        let webhookConfiguration4 = WebhookConfiguration(
            webhookId: "webhookId2",
            name: "configuration1",
            webhookAuthType: .basic,
            webhookAuthParam1: "basic1",
            webhookAuthParam2: "basic2",
            queryParams: ["key": "mykey2", "value": "myValue2"]
        )
        
        container.mainContext.insert(webhookConfiguration1)
        container.mainContext.insert(webhookConfiguration2)
        container.mainContext.insert(webhookConfiguration3)
        container.mainContext.insert(webhookConfiguration4)
        
        return container
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

@available(iOS 18.0, *)
extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var webhookConfigurationSampleData: Self = .modifier(WebhookConfigurationSampleData())
}

struct ContentView: View {
    @Query(filter: #Predicate<WebhookConfiguration> { webhookConfiguration in
        webhookConfiguration.webhookId == "webhookId1"
    }) private var webhookConfigurations: [WebhookConfiguration] // To list
    @Environment(\.modelContext) private var context
    
    var body: some View {
        List(webhookConfigurations) { webhookConfiguration in
            VStack {
                Text(webhookConfiguration.webhookId ?? "noid")
                Text(webhookConfiguration.name ?? "noname")
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    context.insert(
                        WebhookConfiguration(
                            webhookId: "webhookId1",
                            name: "configuration5",
                            webhookAuthType: .basic,
                            webhookAuthParam1: "basic1",
                            webhookAuthParam2: "basic2",
                            httpMethod: .post,
                            jsonText: "{\"key\": \"value\"}"
                        )
                    )
                } label: {
                    Text("Create")
                }
            }
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .webhookConfigurationSampleData) {
    NavigationStack {
        ContentView()
    }
}
