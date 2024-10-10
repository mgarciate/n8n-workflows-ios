//
//  LaunchWebhookView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 23/9/24.
//

import SwiftUI
import SwiftData

struct MyView: View {
    @Binding var webhookConfiguration: WebhookConfiguration
    
    var body: some View {
        TextField("Name", text: $webhookConfiguration.name)
    }
}

struct LaunchWebhookView<ViewModel>: View where ViewModel: LaunchWebhookViewModelProtocol {
    @Query private var webhookConfigurations: [WebhookConfiguration]
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: ViewModel
    @State private var selectedConfiguration: WebhookConfiguration
    
    var body: some View {
        List {
            Section("Manage webhook configurations") {
                Picker("Configuration", selection: $selectedConfiguration) {
                    ForEach(webhookConfigurations, id: \.self) { configuration in
                        VStack {
                            Text(configuration.name ?? "Default").tag("other")
                        }
                        .tag(configuration.id)
                    }
                }
                .pickerStyle(.menu)
                .disabled(webhookConfigurations.isEmpty)
                MyView(webhookConfiguration: $selectedConfiguration)
                Button("New") {
                    context.insert(
                        WebhookConfiguration(
                            webhookId: viewModel.webhook.id,
                            name: "New",
                            httpMethod: HTTPMethod.get
                        )
                    )
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
                    
                    context.insert(webhookConfiguration1)
                    context.insert(webhookConfiguration2)
                    context.insert(webhookConfiguration3)
                    context.insert(webhookConfiguration4)
                }
                Button("onDelete") {
                    context.delete(selectedConfiguration)
                }
                .disabled(webhookConfigurations.count <= 1)
            }
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
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                            TextField("Value", text: $query.value)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
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
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
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
        .alert(isPresented: $viewModel.isAlertPresented) {
            switch viewModel.apiResult {
            case .success(let response):
                Alert(title: Text(viewModel.webhook.name),
                      message: Text(response.message),
                      dismissButton: .default(Text("OK")) {
                    dismiss()
                }
                )
            case .failure(let error):
                Alert(title: Text(error.title),
                      message: Text(error.message),
                      primaryButton: .cancel() {
//                    do nothing
                }, secondaryButton: .default(Text("Retry")) {
                    Task {
                        await viewModel.send()
                    }
                }
                )
            case .none:
                Alert(title: Text("Unknown"),
                      message: Text(""),
                      dismissButton: .default(Text("OK")) {
                    dismiss()
                }
                )
            }
        }
        .onAppear() {
            if let selectedConfiguration = webhookConfigurations.first {
                self.selectedConfiguration = selectedConfiguration
                print("*** \(selectedConfiguration.name)")
            } else {
                context.insert(selectedConfiguration)
            }
        }
    }
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        selectedConfiguration = WebhookConfiguration(
            webhookId: viewModel.webhook.id,
            name: "New",
            httpMethod: HTTPMethod.get
        )
        let webhookId = viewModel.webhook.id
        _webhookConfigurations = Query(filter: #Predicate<WebhookConfiguration> {
            $0.webhookId == webhookId
        })
    }
    
    private func delete(at offsets: IndexSet) {
        viewModel.queryParams.remove(atOffsets: offsets)
    }
}

@available(iOS 18.0, *)
#Preview(traits: .webhookConfigurationSampleData) {
    NavigationStack {
        LaunchWebhookView(viewModel: MockLaunchWebhookViewModel(webhook: Webhook.dummyWebhook))
    }
}
