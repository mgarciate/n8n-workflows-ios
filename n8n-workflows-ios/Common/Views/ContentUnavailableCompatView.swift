//
//  ContentUnavailableCompatView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 18/9/24.
//

import SwiftUI

struct ContentUnavailableCompatView: View {
    let title: String
    let description: String
    let systemImage: String
    
    var body: some View {
        ContentUnavailableView(title,
                               systemImage: systemImage,
                               description: Text(description))
    }
}

#Preview {
    ContentUnavailableCompatView(title: "No data", description: "This is a long description", systemImage: "swiftdata")
}
