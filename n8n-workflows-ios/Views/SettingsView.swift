//
//  SettingsView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 14/9/24.
//

import SwiftUI

struct SettingsView<ViewModel>: View where ViewModel: SettingsViewModelProtocol {
    @Environment(\.dismiss) private var dismiss
    
    @State private var selfhostedPopoverPresented = false
    @State private var apikeyPopoverPresented = false
    @StateObject var viewModel: ViewModel
    @State private var isLogsViewPresented = false
    
    var body: some View {
        NavigationStack {
            List {
                sectionHost
                sectionCredentials
                sectionAuthentication
                Section("Logs") {
                    Button {
                        isLogsViewPresented.toggle()
                    } label: {
                        Text("Show logs")
                    }
                }
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
            .fullScreenCover(isPresented: $isLogsViewPresented) {
                LogsViewer()
            }
        }
    }
    
    var sectionHost: some View {
        Section(content: {
            Toggle("Self-hosted", isOn: $viewModel.selfhostIsOn)
                .onChange(of: viewModel.selfhostIsOn) { _ in // Supported from iOS 14
                    viewModel.url = ""
                }
            TextField(viewModel.selfhostIsOn ? "http://ip-address:port" : "https:// appname.app.n8n.cloud", text: $viewModel.url)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
            if viewModel.url.isEmpty {
                Text("Cannot be empty")
                    .foregroundStyle(.red)
                    .font(.caption.italic())
            }
        }, header: {
            HStack {
                Text("Host")
                Button {
                    selfhostedPopoverPresented = true
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundStyle(.blue)
                .popover(isPresented: $selfhostedPopoverPresented,
                         attachmentAnchor: .point(.center),
                         arrowEdge: .top) {
                    Text("\n\nIf you have n8n self-hosted, a normal configuration would be accessed via http://ip-address:port or https://your-domain. It is necessary to grant permission to access your local network.\nIf you're using n8n Cloud, the configuration would be accessed through https://appname.app.n8n.cloud\n\n")
                        .textCase(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .presentationCompactAdaptation(.none)
                }
            }
        })
    }
    
    var sectionCredentials: some View {
        Section(content: {
            SecureView(titleKey: "API-KEY", text: $viewModel.apiKey)
            if viewModel.apiKey.isEmpty {
                Text("Cannot be empty")
                    .foregroundStyle(.red)
                    .font(.caption.italic())
            }
        }, header: {
            HStack {
                Text("Credentials")
                Button {
                    apikeyPopoverPresented = true
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundStyle(.blue)
                .popover(isPresented: $apikeyPopoverPresented,
                         attachmentAnchor: .point(.center),
                         arrowEdge: .top) {
                    Text("Create an API key\n1. Log in to n8n.\n2. Go to **Settings > n8n API**.\n3. Select **Create an API key**.\n4. Copy **My API Key** and use this key to authenticate your calls.")
                        .textCase(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .presentationCompactAdaptation(.none)
                }
            }
        })
    }
    
    var sectionAuthentication: some View {
        Section("Webhook authentication") {
            Picker("Authentication", selection: $viewModel.webhookAuthenticationType) {
                ForEach(WebhookAuthType.allCases, id: \.self) { value in
                    Text(value.string)
                }
            }
            .onChange(of: viewModel.webhookAuthenticationType) { _ in // Supported from iOS 14
                viewModel.webhookAuthenticationParam1 = ""
                viewModel.webhookAuthenticationParam2 = ""
            }
            switch viewModel.webhookAuthenticationType {
            case .basic:
                TextField("User", text: $viewModel.webhookAuthenticationParam1)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
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
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                if viewModel.webhookAuthenticationParam1.isEmpty {
                    Text("Cannot be empty")
                        .foregroundStyle(.red)
                        .font(.caption.italic())
                }
                TextField("Value", text: $viewModel.webhookAuthenticationParam2, axis: .vertical)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
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
