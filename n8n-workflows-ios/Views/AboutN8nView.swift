//
//  AboutN8nView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 23/9/24.
//


import SwiftUI

struct AboutN8nView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("About n8n")
                .font(.title.bold())
            Text("n8n (pronounced n-eight-n) helps you to connect any app with an API with any other, and manipulate its data with little or no code.\n\n- Customizable: highly flexible workflows and the option to build custom nodes.\n- Convenient: use the npm or Docker to try out n8n, or the Cloud hosting option if you want us to handle the infrastructure.\n- Privacy-focused: self-host n8n for privacy and security.")
            Spacer()
        }
        .padding()
    }
}