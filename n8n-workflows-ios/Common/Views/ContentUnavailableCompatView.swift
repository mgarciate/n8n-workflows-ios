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
        if #available(iOS 17.0, *) {
            ContentUnavailableView(title,
                                   systemImage: systemImage,
                                   description: Text(description))
        } else {
            VStack(spacing: 5) {
                Image.init(systemName: systemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50.0, height: 50.0)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                Text(title)
                    .font(.title2.bold())
                Text(description)
                    .font(.callout)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    ContentUnavailableCompatView(title: "No data", description: "This is a long description", systemImage: "swiftdata")
}
