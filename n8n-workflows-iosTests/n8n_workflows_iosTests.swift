//
//  n8n_workflows_iosTests.swift
//  n8n-workflows-iosTests
//
//  Created by mgarciate on 12/9/24.
//

import Testing
@testable import n8n_workflows_ios

struct n8n_workflows_iosTests {
    
    init() {
        let _ = KeychainHelper.shared.saveApiKey("myapikey1", service: "myservice", account: "myaccount1")
        let _ = KeychainHelper.shared.saveApiKey("myapikey2", service: "myservice", account: "myaccount2")
    }

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        #expect(KeychainHelper.shared.retrieveApiKey(service: "myservice", account: "myaccount1") == "myapikey1")
        #expect(KeychainHelper.shared.retrieveApiKey(service: "myservice", account: "myaccount2") == "myapikey2")
    }

}
