//
//  ChatView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 18/4/25.
//

import SwiftUI

struct ChatView: View {
    let chat: ChatTrigger
    
    private var user: String? {
        chat.authentication == .basic ? UserDefaultsHelper.shared.webhookAuthParam1 : nil
    }
    
    private var password: String? {
        chat.authentication == .basic ? UserDefaultsHelper.shared.webhookAuthParam2 : nil
    }
    
    var body: some View {
        if let baseUrl = UserDefaultsHelper.shared.hostUrl,
           let url = URL(string: baseUrl) {
            let chatUrl = url
                .appendingPathComponent("webhook")
                .appendingPathComponent(chat.id)
                .appendingPathComponent("chat")
            WebView(url: chatUrl, user: user, password: password)
                .edgesIgnoringSafeArea(.bottom)
                .navigationTitle("Chat")
                .navigationBarTitleDisplayMode(.inline)
        } else {
            ContentUnavailableCompatView(
                title: "No content available",
                description: "",
                systemImage: "message"
            )
        }
    }
}

#Preview {
    ChatView(chat: ChatTrigger(id: "", authentication: .noAuth))
}
