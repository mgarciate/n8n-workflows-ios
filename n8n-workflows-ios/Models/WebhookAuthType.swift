//
//  WebhookAuthType.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 20/9/24.
//

enum WebhookAuthType: Codable, CaseIterable {
    case basic
    case header
    case jwt
    case none
    
    var string: String {
        switch self {
        case .basic:
            "Basic Auth"
        case .header:
            "Header Auth"
        case .jwt:
            "JWT Auth"
        case .none:
            "None"
        }
    }
}
