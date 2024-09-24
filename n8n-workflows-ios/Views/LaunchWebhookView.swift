//
//  LaunchWebhookView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 23/9/24.
//

import SwiftUI

struct LaunchWebhookView<ViewModel>: View where ViewModel: LaunchWebhookViewModelProtocol {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        List {
            Section("Webhook request") {
                Picker("Authentication", selection: $viewModel.webhookAuthenticationType) {
                    ForEach(WebhookAuthType.allCases, id: \.self) { value in
                        Text(value.string)
                    }
                }
                .disabled(true)
                Toggle("Test", isOn: $viewModel.test)
                Picker("HTTP Method", selection: $viewModel.httpMethod) {
                    ForEach(HTTPMethod.allCases, id: \.self) { value in
                        Text(value.rawValue)
                    }
                }
                switch viewModel.httpMethod {
                case .get:
                    Text("Query parameters:")
                    ForEach($viewModel.queryParams) { $query in
                        HStack {
                            TextField("Key", text: $query.key)
                            TextField("Value", text: $query.value)
                        }
                    }
                    .onDelete(perform: delete)
                    Button("+ Add parameter") {
                        viewModel.queryParams.append(QueryParam(key: "", value: ""))
                    }
                    .buttonStyle(.automatic)
                case .post:
                    VStack(alignment: .leading) {
                        Text("HTTP Body (json):")
                        TextField("{}", text: $viewModel.jsonText, axis: .vertical)
                            .foregroundStyle(.gray)
                            .keyboardType(.asciiCapable)
                        if !viewModel.validateJson() {
                            Text("Invalid Json")
                                .foregroundStyle(.red)
                                .font(.caption.italic())
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle(viewModel.webhook.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("", systemImage: "paperplane") {
                    Task {
                        await viewModel.send()
                    }
                }
            }
        }
    }
    
    private func delete(at offsets: IndexSet) {
        viewModel.queryParams.remove(atOffsets: offsets)
    }
}

#Preview {
    NavigationStack {
        LaunchWebhookView(viewModel: MockLaunchWebhookViewModel(webhook: Webhook.dummyWebhook))
    }
}
