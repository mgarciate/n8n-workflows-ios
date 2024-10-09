//
//  KeychainHelper.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 12/9/24.
//

import Foundation
import Security

class KeychainHelper: @unchecked Sendable {
    static let teamId = "ZR272F7CTF"
    static let accessGroup = "\(teamId).com.mgarciate.n8n-workflows"
    // TODO: remove this static value
    static let service = "api-key"
    static let account = "Instance1"
    
    static let shared = KeychainHelper()

    private init() {}

    func saveApiKey(_ apiKey: String, service: String, account: String) -> Bool {
        print("saveApiKey: \(apiKey)")
        let data = Data(apiKey.utf8)

        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecAttrAccessGroup: KeychainHelper.accessGroup,
            kSecValueData: data,
            kSecAttrSynchronizable: true,
        ] as [String: Any]

        SecItemDelete(query as CFDictionary)  // Remove existing item if any
        let status = SecItemAdd(query as CFDictionary, nil)

        return status == errSecSuccess
    }

    func retrieveApiKey(service: String, account: String) -> String? {
        print("retrieveApiKey")
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecAttrAccessGroup: KeychainHelper.accessGroup,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecAttrSynchronizable: true,
        ] as [String: Any]

        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func deleteApiKey(service: String, account: String) -> Bool {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecAttrAccessGroup: KeychainHelper.accessGroup,
            kSecAttrSynchronizable: true,
        ] as [String: Any]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}
