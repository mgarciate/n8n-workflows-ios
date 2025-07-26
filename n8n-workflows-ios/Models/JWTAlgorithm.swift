//
//  JWTAlgorithm.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 26/7/25.
//

enum JWTAlgorithm: String, Codable, CaseIterable {
    case HS256
    case HS384
    case HS512
    
    var string: String {
        self.rawValue
    }
}
