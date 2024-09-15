//
//  SheetTitleView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 14/9/24.
//

import SwiftUI

struct SheetTitleView: View {
    let title: String
    let closeAction: () -> Void
    var body: some View {
        HStack {
            Text(title)
                .font(Font.title3.bold())
            Spacer()
            CloseButtonView(action: closeAction)
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
}
