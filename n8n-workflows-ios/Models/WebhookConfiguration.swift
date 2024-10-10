//
//  WebhookConfiguration.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 10/10/24.
//

import SwiftData

@Model
final class WebhookConfiguration {
    var webhookId: String?
    var name: String = "Default"
    var webhookAuthType: String = WebhookAuthType.noAuth.rawValue
    var webhookAuthParam1: String = ""
    var webhookAuthParam2: String = ""
    var httpMethod: String = HTTPMethod.get.rawValue
    var jsonText: String = "{}"
    var queryParams: [String: String] = [:]
    
    init(webhookId: String,
         name: String,
         webhookAuthType: WebhookAuthType = .noAuth,
         webhookAuthParam1: String = "",
         webhookAuthParam2: String = "",
         httpMethod: HTTPMethod = HTTPMethod.get,
         jsonText: String = "{}",
         queryParams: [String: String] = [:]) {
        self.webhookId = webhookId
        self.name = name
        self.webhookAuthType = webhookAuthType.rawValue
        self.webhookAuthParam1 = webhookAuthParam1
        self.webhookAuthParam2 = webhookAuthParam2
        self.httpMethod = httpMethod.rawValue
        self.jsonText = jsonText
        self.queryParams = queryParams
    }
}
