//
//  WorkflowWebhooksView.swift
//  Watchflows Watch App
//
//  Created by mgarciate on 8/10/24.
//

import SwiftUI

struct WorkflowWebhooksView: View {
    @Environment(WorkflowRouter.self) var router
    let workflow: Workflow
    
    var body: some View {
        List {
            Section {
                ForEach(workflow.webhooks) { webhook in
                    Button("Launch \(webhook.name)") {
                        // TODO: Implement webhook
                        print("do something")
                    }
                }
            }
        }
        .navigationTitle("Webhooks")
    }
}

#Preview {
    WorkflowWebhooksView(workflow: Workflow.dummyWorkflows[0])
        .environment(WorkflowRouter())
}
