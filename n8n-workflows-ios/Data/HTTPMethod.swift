//
//  HTTPMethod.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 13/10/24.
//

import Foundation

enum HTTPMethod: String, Codable, CaseIterable {
    case get = "GET"
    case post = "POST"
    
    static func from(_ string: String) -> HTTPMethod {
        return HTTPMethod(rawValue: string) ?? .get
    }
}
