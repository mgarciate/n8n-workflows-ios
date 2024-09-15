//
//  ActionButton.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 14/9/24.
//


import SwiftUI

struct ActionButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .padding(10)
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
                .background(Color.black)
                .cornerRadius(25)
        }
    }
}
