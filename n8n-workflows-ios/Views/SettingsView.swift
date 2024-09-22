//
//  SettingsView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 14/9/24.
//

import SwiftUI

struct SettingsView<ViewModel>: View where ViewModel: SettingsViewModelProtocol {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        NavigationStack {
            List {
                sectionHost
                sectionCredentials
                sectionAuthentication
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        viewModel.save()
                        dismiss()
                    } label: {
                        Text("Save")
                    }
                    .disabled(viewModel.url.isEmpty || viewModel.apiKey.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
    
    var sectionHost: some View {
        Section("Host") {
            Toggle("Self-hosted", isOn: $viewModel.selfhostIsOn)
            TextField(viewModel.selfhostIsOn ? "https://domain:port" : "appname.app.n8n.cloud", text: $viewModel.url)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
            if viewModel.url.isEmpty {
                Text("Cannot be empty")
                    .foregroundStyle(.red)
                    .font(.caption.italic())
            }
        }
    }
    
    var sectionCredentials: some View {
        Section("Credentials") {
            SecureView(titleKey: "API-KEY", text: $viewModel.apiKey)
            if viewModel.apiKey.isEmpty {
                Text("Cannot be empty")
                    .foregroundStyle(.red)
                    .font(.caption.italic())
            }
        }
    }
    
    var sectionAuthentication: some View {
        Section("Webhook authentication") {
            Picker("Authentication", selection: $viewModel.webhookAuthenticationType) {
                ForEach(WebhookAuthType.allCases, id: \.self) { value in
                    Text(value.string)
                }
            }
            .onChange(of: viewModel.webhookAuthenticationType) { value in // Supported from iOS 14
                viewModel.webhookAuthenticationParam1 = ""
                viewModel.webhookAuthenticationParam2 = ""
            }
            switch viewModel.webhookAuthenticationType {
            case .basic:
                TextField("User", text: $viewModel.webhookAuthenticationParam1)
                if viewModel.webhookAuthenticationParam1.isEmpty {
                    Text("Cannot be empty")
                        .foregroundStyle(.red)
                        .font(.caption.italic())
                }
                SecureView(titleKey: "Password", text: $viewModel.webhookAuthenticationParam2)
                if viewModel.webhookAuthenticationParam2.isEmpty {
                    Text("Cannot be empty")
                        .foregroundStyle(.red)
                        .font(.caption.italic())
                }
            case .header:
                TextField("Name", text: $viewModel.webhookAuthenticationParam1)
                if viewModel.webhookAuthenticationParam1.isEmpty {
                    Text("Cannot be empty")
                        .foregroundStyle(.red)
                        .font(.caption.italic())
                }
                TextField("Value", text: $viewModel.webhookAuthenticationParam2, axis: .vertical)
                if viewModel.webhookAuthenticationParam2.isEmpty {
                    Text("Cannot be empty")
                        .foregroundStyle(.red)
                        .font(.caption.italic())
                }
            case .jwt:
                Text("Not supported yet")
                    .foregroundStyle(.red)
                    .font(.caption.italic())
            case .noAuth:
                EmptyView()
            }
        }
    }
}

#Preview {
    SettingsView(viewModel: MockSettingsViewModel())
}
