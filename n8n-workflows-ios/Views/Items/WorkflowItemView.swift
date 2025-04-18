//
//  WorkflowItemView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 18/9/24.
//

import SwiftUI

struct LaunchWebhookButtonStyle: ButtonStyle {
    var backgroundColor: Color = .blue
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(backgroundColor)
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .clipShape(Capsule())
    }
}

struct WorkflowItemView: View {
    let workflow: Workflow
    let action: (Bool) -> Void
    let launchWebhook: (Webhook) -> Void
    let launchChat: (ChatTrigger) -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 1.0, green: 0.4, blue: 0.4))
                .shadow(radius: 5)
            HStack {
                ZStack {
                    VStack(alignment: .leading) {
                        Text(workflow.name)
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                        HStack(alignment: .bottom, spacing: 5) {
                            Text("Last update")
                                .font(.caption.italic())
                            Text(workflow.updatedAt.date?.timeAgoDisplay ?? "-")
                                .font(.subheadline.bold())
                            Spacer()
                        }
                        .foregroundStyle(.white.opacity(0.7))
                        ForEach(workflow.chatTriggers) { chat in
                            Button(action: {
                                launchChat(chat)
                            }) {
                                Label {
                                    Text("Open chat")
                                        .padding(.leading, -5)
                                        .font(.subheadline)
                                } icon: {
                                    Image(systemName: "message")
                                }
                            }
                            .buttonStyle(
                                LaunchWebhookButtonStyle(backgroundColor: Color("Red"))
                            )
                        }
                        ForEach(workflow.webhooks) { webhook in
                            Button(action: {
                                launchWebhook(webhook)
                            }) {
                                Label {
                                    Text("Launch \(webhook.name)")
                                        .padding(.leading, -5)
                                        .font(.subheadline)
                                } icon: {
                                    Image(systemName: "paperplane")
                                }
                            }
                            .buttonStyle(
                                LaunchWebhookButtonStyle(backgroundColor: Color(red: 66/255, green: 95/255, blue: 185/255))
                            )
                        }
                    }
                }
                VStack {
                    Toggle("", isOn: Binding(
                        get: { workflow.active },
                        set: { newValue in
                            action(newValue)
                        }
                    ))
                    .onTapGesture {
                        action(!workflow.active)
                    }
                    .labelsHidden()
                    Spacer()
                }
            }
            .padding()
        }
    }
}

@available(iOS 17, *)
#Preview(traits: .sizeThatFitsLayout) {
    WorkflowItemView(workflow: Workflow.dummyWorkflows[0], action: { _ in
        
    }, launchWebhook: { webhook in
        
    }, launchChat: { chat in
        
    })
}
