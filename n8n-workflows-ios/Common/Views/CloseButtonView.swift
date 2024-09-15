//
//  CloseButtonView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 14/9/24.
//

import SwiftUI

struct CloseButtonView: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "multiply")
                .resizable()
                .scaledToFit()
                .padding(5)
                .foregroundColor(Color("White"))
                .background(Color("Black"))
                .cornerRadius(15)
            
        }
        .frame(height: 30)
    }
}
