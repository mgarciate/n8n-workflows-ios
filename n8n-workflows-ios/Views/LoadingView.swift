//
//  LoadingView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 18/10/24.
//

import SwiftUI

struct LoadingView: View {
    let isLoading: Bool
    
    var body: some View {
        ZStack {
            Color.clear
            ZStack {
                ProgressView("Loading n8n data...")
                    .tint(.white)
                    .foregroundStyle(.white)
                    .controlSize(.large)
                    .padding()
                    .background(.black.opacity(0.7))
            }
        }
        .transition(.opacity.animation(.easeInOut(duration: 0.5)))
        .allowsHitTesting(!isLoading)
    }
}

#Preview {
    LoadingView(isLoading: true)
}
