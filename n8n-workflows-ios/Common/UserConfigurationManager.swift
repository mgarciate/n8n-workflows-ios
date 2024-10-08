//
//  UserConfigurationManager.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 8/10/24.
//


import SwiftData

@Model
final class UserConfiguration {
    var hostUrl: String?
    var webhookAuthType: WebhookAuthType?
    var webhookAuthParam1: String?
    var webhookAuthParam2: String?
    var selfHost: Bool

    init(hostUrl: String? = nil,
         webhookAuthType: WebhookAuthType? = nil,
         webhookAuthParam1: String? = nil,
         webhookAuthParam2: String? = nil,
         selfHost: Bool = false) {
        self.hostUrl = hostUrl
        self.webhookAuthType = webhookAuthType
        self.webhookAuthParam1 = webhookAuthParam1
        self.webhookAuthParam2 = webhookAuthParam2
        self.selfHost = selfHost
    }
}

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: ModelContainer

    private init() {
        let schema = Schema([UserConfiguration.self])
        container = try! ModelContainer(for: schema)
    }
}

@MainActor
class UserConfigurationManager {
    static let shared = UserConfigurationManager()
    private let context: ModelContext
    private var userConfiguration: UserConfiguration

    private init() {
        context = PersistenceController.shared.container.mainContext

        let fetchDescriptor = FetchDescriptor<UserConfiguration>()
        if let existingConfig = try? context.fetch(fetchDescriptor).first {
            userConfiguration = existingConfig
        } else {
            userConfiguration = UserConfiguration()
            context.insert(userConfiguration)
            try? context.save()
        }
    }

    var hostUrl: String? {
        get { userConfiguration.hostUrl }
        set {
            userConfiguration.hostUrl = newValue
            try? context.save()
        }
    }

    var webhookAuthType: WebhookAuthType? {
        get { userConfiguration.webhookAuthType }
        set {
            userConfiguration.webhookAuthType = newValue
            try? context.save()
        }
    }

    var webhookAuthParam1: String? {
        get { userConfiguration.webhookAuthParam1 }
        set {
            userConfiguration.webhookAuthParam1 = newValue
            try? context.save()
        }
    }

    var webhookAuthParam2: String? {
        get { userConfiguration.webhookAuthParam2 }
        set {
            userConfiguration.webhookAuthParam2 = newValue
            try? context.save()
        }
    }

    var selfHost: Bool {
        get { userConfiguration.selfHost }
        set {
            userConfiguration.selfHost = newValue
            try? context.save()
        }
    }
}
