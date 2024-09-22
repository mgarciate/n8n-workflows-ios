//
//  WorkflowItemView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 18/9/24.
//

import SwiftUI

struct WorkflowItemView: View {
    let workflow: Workflow
    let action: (Bool) -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(workflow.name)
                    .fontWeight(.bold)
                HStack(alignment: .bottom, spacing: 5) {
                    Text("Last update")
                        .font(.caption.italic())
                    Text(workflow.updatedAt.date?.timeAgoDisplay ?? "-")
                        .font(.subheadline.bold())
                    Spacer()
                }
                .foregroundStyle(Color("Gray"))
                ForEach(workflow.webhooks) { webhook in
                    Button("Launch \(webhook.name)") {
                        print("webhook \(webhook.path)")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                }
            }
            Toggle("", isOn: Binding(
                get: { workflow.active },
                set: { newValue in
                    action(newValue)
                }
            ))
            .labelsHidden()
        }
    }
}

@available(iOS 17, *)
#Preview(traits: .sizeThatFitsLayout) {
    WorkflowItemView(workflow: Workflow.dummyWorkflows[0]) {_ in 
        
    }
}
