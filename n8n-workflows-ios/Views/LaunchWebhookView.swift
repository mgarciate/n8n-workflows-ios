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
                            Text(configuration.name).tag("other")
                        }
                        .tag(configuration.id)
                    }
                }
                .pickerStyle(.menu)
                .disabled(webhookConfigurations.isEmpty)
                MyView(webhookConfiguration: $selectedConfiguration)
            }
            Section("Webhook request") {
                Picker("Authentication", selection: Binding(
                    get: { WebhookAuthType.from(selectedConfiguration.webhookAuthType) },
                    set: { selectedConfiguration.webhookAuthType = $0.rawValue }
                )) {
                    ForEach(WebhookAuthType.allCases, id: \.self) { value in
                        Text(value.string)
                    }
                }
                Toggle("Test", isOn: $viewModel.test)
                Picker("HTTP Method", selection: Binding(
                    get: { HTTPMethod.from(selectedConfiguration.httpMethod) },
                    set: { selectedConfiguration.httpMethod = $0.rawValue }
                )) {
                    ForEach(HTTPMethod.allCases, id: \.self) { value in
                        Text(value.rawValue )
                    }
                }
                switch selectedConfiguration.httpMethodOrDefault {
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
                    .onChange(of: viewModel.queryParams) { oldValue, newValue in
                        selectedConfiguration.queryParams = [:]
                        viewModel.queryParams.forEach {
                            selectedConfiguration.queryParams[$0.key] = $0.value
                            try? context.save()
                        }
                    }
                    Button("+ Add parameter") {
                        viewModel.queryParams.append(QueryParam(key: "", value: ""))
                    }
                    .buttonStyle(.automatic)
                case .post:
                    VStack(alignment: .leading) {
                        Text("HTTP Body (json):")
                        TextField("{}", text: $selectedConfiguration.jsonText, axis: .vertical)
                            .foregroundStyle(.gray)
                            .keyboardType(.asciiCapable)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                        if !viewModel.validateJson(selectedConfiguration.jsonText) {
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
            ToolbarItem(placement: .automatic) {
                Button("", systemImage: "plus") {
                    let newWebhookConfiguration = WebhookConfiguration(
                        webhookId: viewModel.webhook.id,
                        name: "<New>",
                        httpMethod: HTTPMethod.get
                    )
                    context.insert(newWebhookConfiguration)
                    selectedConfiguration = newWebhookConfiguration
                }
            }
            ToolbarItem(placement: .automatic) {
                Button("", systemImage: "trash") {
                    context.delete(selectedConfiguration)
                    if let firstConfiguration = webhookConfigurations.first {
                        selectedConfiguration = firstConfiguration
                    }
                }
                .disabled(webhookConfigurations.count <= 1)
            }
            ToolbarItem(placement: .primaryAction) {
                Button("", systemImage: "paperplane") {
                    Task {
                        await viewModel.send(with: selectedConfiguration)
                    }
                }
                .disabled(
                    selectedConfiguration.httpMethodOrDefault == .post &&
                    !viewModel.validateJson(selectedConfiguration.jsonText)
                )
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
                        await viewModel.send(with: selectedConfiguration)
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
