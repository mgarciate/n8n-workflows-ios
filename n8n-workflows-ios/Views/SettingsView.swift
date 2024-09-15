//
//  SettingsView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 14/9/24.
//

import SwiftUI



struct SettingsView: View {
    @Binding var actionSheet: MainActionSheet?
    @AppStorage("autohost") var autohostIsOn: Bool = false
    @AppStorage("url") var url: String = ""
    @AppStorage("apiKey") var apiKey: String = ""
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
                                    SecureField("API-KEY", text: $apiKey)
                                } else {
                                    TextField("API-KEY", text: $apiKey, axis: .vertical)
                                }
                            }.padding(.trailing, 32)
                            Button(action: {
                                isSecured.toggle()
                            }) {
                                Image(systemName: self.isSecured ? "eye.slash" : "eye")
                                    .accentColor(.gray)
                            }
                        }
                        if apiKey.isEmpty {
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
    SettingsView(actionSheet: .constant(.settings))
}
