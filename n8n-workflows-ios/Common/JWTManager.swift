//
//  JWTManager.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 26/7/25.
//

import Foundation
import CryptoKit

struct JWTManager {
    
    static func generateToken(header: [String: Any] = [:],
                              payload: [String: Any],
                              secret: String,
                              algorithm: JWTAlgorithm) -> String? {
        let headerArray: [(String, Any)] = [
            ("alg", algorithm.rawValue),
            ("typ", "JWT"),
        ]
        
        let header = Dictionary(headerArray, uniquingKeysWith: { first, _ in first })
        
        guard let headerData = try? JSONSerialization.data(withJSONObject: header, options: []),
              let payloadData = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            return nil
        }
        
        let headerBase64 = base64UrlEncode(data: headerData)
        let payloadBase64 = base64UrlEncode(data: payloadData)
        
        let message = "\(headerBase64).\(payloadBase64)"
        
        guard let signature = sign(message: message, secret: secret, algorithm: algorithm) else { return nil }
        
        return "\(message).\(signature)"
    }
    
    // MARK: - Private
    
    private static func base64UrlEncode(data: Data) -> String {
        let base64 = data.base64EncodedString()
        return base64
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
    private static func sign(message: String, secret: String, algorithm: JWTAlgorithm) -> String? {
        guard let keyData = secret.data(using: .utf8),
              let messageData = message.data(using: .utf8) else {
            return nil
        }
        
        let key = SymmetricKey(data: keyData)
        let signature: Data
        
        switch algorithm {
        case .HS256:
            signature = Data(HMAC<SHA256>.authenticationCode(for: messageData, using: key))
        case .HS384:
            signature = Data(HMAC<SHA384>.authenticationCode(for: messageData, using: key))
        case .HS512:
            signature = Data(HMAC<SHA512>.authenticationCode(for: messageData, using: key))
        }
        
        return base64UrlEncode(data: signature)
    }
}

