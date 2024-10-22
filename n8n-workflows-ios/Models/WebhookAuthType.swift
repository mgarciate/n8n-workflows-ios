//
//  WebhookAuthType.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 20/9/24.
//

enum WebhookAuthType: String, Codable, CaseIterable {
    case basic
    case header
    case jwt
    case noAuth
    
    var string: String {
        switch self {
        case .basic:
            "Basic Auth"
        case .header:
            "Header Auth"
        case .jwt:
            "JWT Auth"
        case .noAuth:
            "None"
        }
    }
    
    static func from(_ string: String) -> WebhookAuthType {
        return WebhookAuthType(rawValue: string) ?? .noAuth
    }
}
