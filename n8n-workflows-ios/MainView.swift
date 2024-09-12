//
//  MainView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 12/9/24.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            List(Range(1...10)) { i in
                Text("\(i)")
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    MainView()
}
