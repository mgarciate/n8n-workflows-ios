//
//  SettingsView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 14/9/24.
//

import SwiftUI




final class SettingsViewModel: SettingsViewModelProtocol {
    @Published var apiKey: String = ""
    var apiKeyBinding: Binding<String> {
        Binding(
            get: { self.apiKey },
            set: { newValue in
                self.apiKey = newValue
                self.saveApiKey()
            }
        )
    }
    
    init() {
        apiKey = KeychainHelper.shared.retrieveApiKey(
            service: KeychainHelper.service,
            account: KeychainHelper.account
        ) ?? ""
    }
    
    private func saveApiKey() {
        _ = KeychainHelper.shared.saveApiKey(
            apiKey,
            service: KeychainHelper.service,
            account: KeychainHelper.account
        )
    }
}

struct SettingsView<ViewModel>: View where ViewModel: SettingsViewModelProtocol {
    @StateObject var viewModel: ViewModel
    @Binding var actionSheet: MainActionSheet?
    @AppStorage("autohost") var autohostIsOn: Bool = false
    @AppStorage("url") var url: String = ""
    @State var isSecured: Bool = true
    var body: some View {
        VStack {
            SheetTitleView(title: "Settings", closeAction: {
                actionSheet = nil
            })
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
            Spacer()
        }
    }
}

#Preview {
    SettingsView(viewModel: MockSettingsViewModel(), actionSheet: .constant(.settings))
}
