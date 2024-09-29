//
//  OnboardingView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 28/9/24.
//

import SwiftUI

struct ShortcutsHelpView: View {
    var body: some View {
        List {
            Section {
                Text("How to create Shortcuts using workflows")
                    .font(.title3)
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
                    Text("Scroll down and select **App**")
                }
                HStack {
                    Text("TODO: Image here")
                        .padding()
                        .foregroundStyle(.white)
                        .background(.red)
                }
            }
            Section {
                HStack(alignment: .top, spacing: 10.0) {
                    Text("3")
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
