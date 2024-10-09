//
//  UserConfigurationManager.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 8/10/24.
//


import CloudKit

final class UserConfiguration {
    let selfHost: Bool?
    let hostUrl: String?
    let webhookAuthType: WebhookAuthType?
    let webhookAuthParam1: String?
    let webhookAuthParam2: String?

    init(selfHost: Bool? = false,
         hostUrl: String? = nil,
         webhookAuthType: WebhookAuthType? = nil,
         webhookAuthParam1: String? = nil,
         webhookAuthParam2: String? = nil) {
        self.selfHost = selfHost
        self.hostUrl = hostUrl
        self.webhookAuthType = webhookAuthType
        self.webhookAuthParam1 = webhookAuthParam1
        self.webhookAuthParam2 = webhookAuthParam2
    }
    
    convenience init(record: CKRecord) {
        let selfHost = record["selfHost"] as? Bool
        let hostUrl = record["hostUrl"] as? String
        let webhookAuthTypeRaw = record["webhookAuthType"] as? String
        let webhookAuthParam1 = record["webhookAuthParam1"] as? String
        let webhookAuthParam2 = record["webhookAuthParam2"] as? String
        
        let webhookAuthType: WebhookAuthType?
        if let webhookAuthTypeRaw {
            webhookAuthType = WebhookAuthType(rawValue: webhookAuthTypeRaw)
        } else {
            webhookAuthType = nil
        }
        
        self.init(selfHost: selfHost,
                  hostUrl: hostUrl,
                  webhookAuthType: webhookAuthType,
                  webhookAuthParam1: webhookAuthParam1,
                  webhookAuthParam2: webhookAuthParam2)
    }
}

class UserConfigurationManager {
    static let shared = UserConfigurationManager()
    
    private let privateDatabase = CKContainer(identifier: "iCloud.com.mgarciate.n8n-workflows").privateCloudDatabase
    private let recordType = "Settings"
    private var currentRecordID: CKRecord.ID?
    
    private init() {
        // Load currentRecordID from UserDefaults if it's stored?
    }
    
    private func saveSettings(_ userConfig: UserConfiguration) async throws {
        let record = CKRecord(recordType: recordType)
        try setRecordFields(record, from: userConfig)
        
        let savedRecord = try await privateDatabase.save(record)
        self.currentRecordID = savedRecord.recordID
        // Optionally, persist currentRecordID in UserDefaults.
    }
    
    func fetchSettings() async throws -> UserConfiguration {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        
        let (matchedResults, _) = try await privateDatabase.records(matching: query)
        
        if let firstResult = matchedResults.first {
            let record = try firstResult.1.get()
            self.currentRecordID = record.recordID
            let userConfig = UserConfiguration(record: record)
            return userConfig
        } else {
            throw NSError(domain: "NoData", code: 0, userInfo: [NSLocalizedDescriptionKey: "No se encontraron configuraciones."])
        }
    }
    
    func updateSettings(_ userConfig: UserConfiguration) async throws {
        guard let recordID = currentRecordID else {
            // No existing recordID; save new configurations
            try await saveSettings(userConfig)
            return
        }
        
        let record = try await privateDatabase.record(for: recordID)
        try setRecordFields(record, from: userConfig)
        
        let _ = try await privateDatabase.save(record)
    }
    
    private func setRecordFields(_ record: CKRecord, from userConfig: UserConfiguration) throws {
        // Sets the fields of a CKRecord from a UserConfiguration instance.
        if let hostUrl = userConfig.hostUrl {
            record["hostUrl"] = hostUrl as CKRecordValue
        } else {
            record["hostUrl"] = nil
        }
        
        if let webhookAuthType = userConfig.webhookAuthType {
            record["webhookAuthType"] = webhookAuthType.rawValue as CKRecordValue
        } else {
            record["webhookAuthType"] = nil
        }
        
        if let webhookAuthParam1 = userConfig.webhookAuthParam1 {
            record["webhookAuthParam1"] = webhookAuthParam1 as CKRecordValue
        } else {
            record["webhookAuthParam1"] = nil
        }
        
        if let webhookAuthParam2 = userConfig.webhookAuthParam2 {
            record["webhookAuthParam2"] = webhookAuthParam2 as CKRecordValue
        } else {
            record["webhookAuthParam2"] = nil
        }
        
        if let selfHost = userConfig.selfHost {
            record["selfHost"] = selfHost as CKRecordValue
        } else {
            record["selfHost"] = nil
        }
    }
}
