//
//  KeychainHelper.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 12/9/24.
//

import Foundation
import Security

class KeychainHelper: @unchecked Sendable {
    // TODO: remove this static value
    static let service = "api-key"
    static let account = "Instance1"
    
    static let shared = KeychainHelper()

    private init() {}

    func saveApiKey(_ apiKey: String, service: String, account: String) -> Bool {
        print("saveApiKey: \(apiKey)")
        let data = Data(apiKey.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
        ]

        SecItemDelete(query as CFDictionary)  // Remove existing item if any
        let status = SecItemAdd(query as CFDictionary, nil)

        return status == errSecSuccess
    }

    func retrieveApiKey(service: String, account: String) -> String? {
        print("retrieveApiKey")
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func deleteApiKey(service: String, account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}
