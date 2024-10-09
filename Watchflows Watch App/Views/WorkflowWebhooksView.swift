//
//  WorkflowWebhooksView.swift
//  Watchflows Watch App
//
//  Created by mgarciate on 8/10/24.
//

import SwiftUI

final class WorkflowWebhooksViewModel: ObservableObject {
    @Published var webhook: Webhook?
    @Published var isAlertPresented: Bool = false
    @Published var apiResult: Result<WebhookResponse, ApiError>?
    
    func send(webhook: Webhook) async {
        self.webhook = webhook
        let result: Result<WebhookResponse, ApiError>
        do {
            let response: WebhookResponse = try await WebhookRequest().get(endpoint: .webhook(id: webhook.id, isTest: false), params: [:])
            result = .success(response)
        } catch {
#if DEBUG
            print("Error", error)
#endif
            guard let error = error as? ApiError else { return }
            result = .failure(error)
        }
        await MainActor.run {
            isAlertPresented = true
            apiResult = result
        }
    }
}

struct WorkflowWebhooksView: View {
    @Environment(WorkflowRouter.self) var router
    @StateObject var viewModel = WorkflowWebhooksViewModel()
    let workflow: Workflow
    
    var body: some View {
        List {
            Section {
                ForEach(workflow.webhooks) { webhook in
                    Button("{GET} Launch \(webhook.name)") {
                        Task {
                            await viewModel.send(webhook: webhook)
                        }
                    }
                }
            }
        }
        .navigationTitle("Webhooks")
        .alert(isPresented: $viewModel.isAlertPresented) {
            switch viewModel.apiResult {
            case .success(let response):
                Alert(title: Text(viewModel.webhook?.name ?? ""),
                      message: Text(response.message),
                      dismissButton: .default(Text("OK")) {
                    // TODO: dismiss?
                }
                )
            case .failure(let error):
                Alert(title: Text(error.title),
                      message: Text(error.message),
                      primaryButton: .cancel() {
//                    do nothing
                }, secondaryButton: .default(Text("Retry")) {
                    guard let webhook = viewModel.webhook else { return }
                    Task {
                        await viewModel.send(webhook: webhook)
                    }
                }
                )
            case .none:
                Alert(title: Text("Unknown"),
                      message: Text(""),
                      dismissButton: .default(Text("OK")) {
                    // TODO: dismiss?
                }
                )
            }
        }
    }
}

#Preview {
    WorkflowWebhooksView(workflow: Workflow.dummyWorkflows[0])
        .environment(WorkflowRouter())
}
