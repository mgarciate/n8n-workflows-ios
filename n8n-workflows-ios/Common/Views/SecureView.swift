//
//  SecureView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 20/9/24.
//

import SwiftUI

struct SecureView: View {
    let titleKey: LocalizedStringKey
    let text: Binding<String>
    
    @State var isSecured: Bool = true
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Group {
                if isSecured {
                    SecureField(titleKey, text: text)
                } else {
                    TextField(titleKey, text: text, axis: .vertical)
                }
            }.padding(.trailing, 32)
            Button(action: {
                isSecured.toggle()
            }) {
                Image(systemName: self.isSecured ? "eye.slash" : "eye")
                    .accentColor(.gray)
            }
        }
    }
}
