//
//  ChatTrigger.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 19/4/25.
//

struct ChatTrigger: Identifiable, Hashable {
    let id: String
    let authentication: WebhookAuthType
}
