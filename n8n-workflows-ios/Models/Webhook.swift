//
//  Webhook.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 23/9/24.
//


import AppIntents

struct Webhook: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let path: String
}

extension Webhook {
    static var dummyWebhook: Webhook {
        Webhook(id: "webhookId1", name: "webhookName1", path: "webhookPath1")
    }
}
