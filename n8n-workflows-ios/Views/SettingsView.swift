//
//  SettingsView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 14/9/24.
//

import SwiftUI

struct SettingsView: View {
    @Binding var actionSheet: MainActionSheet?
    var body: some View {
        VStack {
            SheetTitleView(title: "Settings", closeAction: {
                actionSheet = nil
            })
            Spacer()
        }
    }
}

#Preview {
    SettingsView(actionSheet: .constant(.settings))
}
