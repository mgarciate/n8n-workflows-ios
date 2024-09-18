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
    @State var isSecured: Bool = true
    
    @AppStorage("autohost") var autohostIsOn: Bool = false
    @AppStorage("url") var url: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section("Host") {
                    Toggle("Self-hosted", isOn: $autohostIsOn)
                    if autohostIsOn {
                        VStack(alignment: .leading) {
                            TextField("https://domain:port", text: $url)
                                .keyboardType(.URL)
                                .textInputAutocapitalization(.never)
                            if url.isEmpty {
                                Text("Cannot be empty")
                                    .foregroundStyle(.red)
                                    .font(.caption.italic())
                            }
                        }
                    }
                }
                Section("Credentials") {
                    VStack(alignment: .leading) {
                        ZStack(alignment: .trailing) {
                            Group {
                                if isSecured {
                                    SecureField("API-KEY", text: viewModel.apiKeyBinding)
                                } else {
                                    TextField("API-KEY", text: viewModel.apiKeyBinding, axis: .vertical)
                                }
                            }.padding(.trailing, 32)
                            Button(action: {
                                isSecured.toggle()
                            }) {
                                Image(systemName: self.isSecured ? "eye.slash" : "eye")
                                    .accentColor(.gray)
                            }
                        }
                        if viewModel.apiKey.isEmpty {
                            Text("Cannot be empty")
                                .foregroundStyle(.red)
                                .font(.caption.italic())
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Save")
                    }
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
}

#Preview {
    SettingsView(viewModel: MockSettingsViewModel())
}
