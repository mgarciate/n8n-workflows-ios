//
//  Webhook.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 23/9/24.
//

import Foundation
import SwiftData

@Model
final class Webhook {
    @Attribute(.unique) var id: String
    var name: String
    var path: String
    
    init(id: String, name: String, path: String) {
        self.id = id
        self.name = name
        self.path = path
    }
}

extension Webhook {
    static var dummyWebhook: Webhook {
        Webhook(id: "webhookId", name: "webhookName", path: "webhookPath")
    }
}
