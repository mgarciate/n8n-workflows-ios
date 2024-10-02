//
//  SampleData.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 1/10/24.
//

import SwiftUI
import SwiftData

struct SampleData: PreviewModifier {
    
    static func makeSharedContext() async throws -> ModelContainer {
        let schema = Schema([Webhook.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        
        let webhook1 = Webhook(id: "webhookId1", name: "webhookName1", path: "webhookPath1")
        let webhook2 = Webhook(id: "webhookId2", name: "webhookName2", path: "webhookPath2")
        
        container.mainContext.insert(webhook1)
        container.mainContext.insert(webhook2)
        
        return container
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

@available(iOS 18.0, *)
extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var sampleData: Self = .modifier(SampleData())
}

struct ContentView: View {
    @Query private var webhooks: [Webhook] // To list
    @Environment(\.modelContext) private var context
    
    var body: some View {
        List(webhooks) { webhook in
            VStack {
                Text(webhook.id)
                Text(webhook.name)
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    let webhook = Webhook(id: "webhookId", name: "webhookName", path: "webhookPath")
                    context.insert(webhook)
                } label: {
                    Text("Create")
                }
            }
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .sampleData) {
    ContentView()
}
