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
                        .font(.title3)
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
                Button("Open the **Shortcuts** app") {
                    guard let url = URL(string: "shortcuts://create-shortcut") else { return }
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
                    Text("Search for and select the **n8n Workflows** app.")
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
                    Text("Choose the **n8n Workouts** app")
                }
                HStack {
                    Text("TODO: Image here")
                        .padding()
                        .foregroundStyle(.white)
                        .background(.red)
                }
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
