//
//  LaunchWebhookView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 23/9/24.
//

import SwiftUI
import SwiftData

struct WebhookConfigurationSectionView: View {
    @Binding var webhookConfiguration: WebhookConfiguration
    let webhookConfigurations: [WebhookConfiguration]
    
    var body: some View {
        Section("Manage webhook profiles") {
            Picker("Profile", selection: $webhookConfiguration) {
                ForEach(webhookConfigurations, id: \.self) { configuration in
                    VStack {
                        Text(configuration.name).tag("other")
                    }
                    .tag(configuration.id)
                }
            }
            .pickerStyle(.menu)
            .disabled(webhookConfigurations.isEmpty)
            TextField("Name", text: $webhookConfiguration.name)
        }
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
            WebhookConfigurationSectionView(webhookConfiguration: $selectedConfiguration, webhookConfigurations: webhookConfigurations)
            Section("Webhook request") {
                Picker("Authentication", selection: Binding(
                    get: { WebhookAuthType.from(selectedConfiguration.webhookAuthType) },
                    set: { selectedConfiguration.webhookAuthType = $0.rawValue }
                )) {
                    ForEach(WebhookAuthType.allCases, id: \.self) { value in
                        Text(value == WebhookAuthType.noAuth ? "Default" : value.string)
                    }
                }
                .onChange(of: selectedConfiguration.webhookAuthType) { _, _ in
                    selectedConfiguration.webhookAuthParam1 = ""
                    selectedConfiguration.webhookAuthParam2 = ""
                }
                switch WebhookAuthType(rawValue: selectedConfiguration.webhookAuthType) {
                case .basic:
                    TextField("User", text: $selectedConfiguration.webhookAuthParam1)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    if selectedConfiguration.webhookAuthParam1.isEmpty {
                        Text("Cannot be empty")
                            .foregroundStyle(.red)
                            .font(.caption.italic())
                    }
                    SecureView(titleKey: "Password", text: $selectedConfiguration.webhookAuthParam2)
                    if selectedConfiguration.webhookAuthParam2.isEmpty {
                        Text("Cannot be empty")
                            .foregroundStyle(.red)
                            .font(.caption.italic())
                    }
                case .header:
                    TextField("Name", text: $selectedConfiguration.webhookAuthParam1)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    if selectedConfiguration.webhookAuthParam1.isEmpty {
                        Text("Cannot be empty")
                            .foregroundStyle(.red)
                            .font(.caption.italic())
                    }
                    TextField("Value", text: $selectedConfiguration.webhookAuthParam2, axis: .vertical)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    if selectedConfiguration.webhookAuthParam2.isEmpty {
                        Text("Cannot be empty")
                            .foregroundStyle(.red)
                            .font(.caption.italic())
                    }
                case .jwt:
                    Text("Not supported yet")
                        .foregroundStyle(.red)
                        .font(.caption.italic())
                case .noAuth, .none:
                    EmptyView()
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
                    let index = webhookConfigurations.count(where: { $0.name.starts(with: WebhookConfiguration.defaultName) })
                    let newWebhookConfiguration = WebhookConfiguration.buildDefaultConfiguration(webhookId: viewModel.webhook.id, index: index > 0 ? (index + 1) : nil)
                    context.insert(newWebhookConfiguration)
                    selectedConfiguration = newWebhookConfiguration
                }
            }
            ToolbarItem(placement: .automatic) {
                Button("", systemImage: "trash") {
                    context.delete(selectedConfiguration)
                    try? context.save() // Necessary to succeed the next if
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
        selectedConfiguration = WebhookConfiguration.buildDefaultConfiguration(webhookId: viewModel.webhook.id)
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
