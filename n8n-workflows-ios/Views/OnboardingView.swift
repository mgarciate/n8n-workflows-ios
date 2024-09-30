//
//  OnboardingView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 28/9/24.
//

import SwiftUI

struct ShortcutsHelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("How to create Shortcuts using workflows")
                    Spacer()
                    CloseButtonView {
                        dismiss()
                    }
                }
            }
            Section("Step by step") {
                HStack(alignment: .top, spacing: 10.0) {
                    Text("1")
                        .font(.title2)
                        .padding()
                        .foregroundStyle(.white)
                        .background(.gray)
                        .clipShape(.circle)
                    Text("Open the **Shortcuts** app.\n\nAt the bottom, select the **Shortcuts** tab and tap + to create a new Shortcut.")
                }
                .listRowSeparator(.hidden)
                Button("Open the **Shortcuts** app") {
                    guard let url = URL(string: "shortcuts://create-shortcut"), UIApplication.shared.canOpenURL(url) else { return }
                    UIApplication.shared.open(url)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(.capsule)
                Image("shortcuts_setup1")
                    .resizable()
                    .scaledToFit()
            }
            Section {
                HStack(alignment: .top, spacing: 10.0) {
                    Text("2")
                        .font(.title2)
                        .padding()
                        .foregroundStyle(.white)
                        .background(.gray)
                        .clipShape(.circle)
                    Text("Select the **Add Action** button to add the action to the workflow.")
                }
                Image("shortcuts_setup2")
                    .resizable()
                    .scaledToFit()
            }
            Section {
                HStack(alignment: .top, spacing: 10.0) {
                    Text("3")
                        .font(.title2)
                        .padding()
                        .foregroundStyle(.white)
                        .background(.gray)
                        .clipShape(.circle)
                    Text("1. Search for and select the **n8n Workflows** app.\n\n2. And also select the action you want: activate or deactivate workflow.")
                }
                Image("shortcuts_setup3")
                    .resizable()
                    .scaledToFit()
            }
            Section {
                HStack(alignment: .top, spacing: 10.0) {
                    Text("4")
                        .font(.title2)
                        .padding()
                        .foregroundStyle(.white)
                        .background(.gray)
                        .clipShape(.circle)
                    Text("The next step is to configure the action. To do this:\n\n1. Expand the configuration.\n\n2. Choose the workflow you would like to select.")
                }
                Image("shortcuts_setup4")
                    .resizable()
                    .scaledToFit()
            }
            Section {
                HStack(alignment: .top, spacing: 10.0) {
                    Text("5")
                        .font(.title2)
                        .padding()
                        .foregroundStyle(.white)
                        .background(.gray)
                        .clipShape(.circle)
                    Text("**Important:** You can rename the **Shortcut** so that it's more intuitive to launch it by calling Siri. For example, \"Start my custom workout.\"")
                }
                Image("shortcuts_setup5")
                    .resizable()
                    .scaledToFit()
            }
            Section {
                HStack(alignment: .top, spacing: 10.0) {
                    Text("6")
                        .font(.title2)
                        .padding()
                        .foregroundStyle(.white)
                        .background(.gray)
                        .clipShape(.circle)
                    Text("**One more thing:** Additionally, you can use actions to activate or deactivate workflows to include them in your iPhone's automations.")
                }
                Image("shortcuts_setup6")
                    .resizable()
                    .scaledToFit()
            }
            Section {
                HStack(alignment: .top, spacing: 10.0) {
                    Text("7")
                        .font(.title2)
                        .padding()
                        .foregroundStyle(.white)
                        .background(.gray)
                        .clipShape(.circle)
                    Text("For example, you can activate or deactivate your n8n workflows when you arrive at a location (your home?), when you receive an email with a specific subject, when you start an app and want to have a service running on your server and shut it down when the app is closed, when you get in the car, when you connect to a specific Wi-Fi, when your iPhone is running low on battery, etc.")
                }
                Image("shortcuts_setup7")
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}

struct OnboardingView: View {
    var body: some View {
        ShortcutsHelpView()
    }
}

#Preview {
    OnboardingView()
}
