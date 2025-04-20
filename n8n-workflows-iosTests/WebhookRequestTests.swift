//
//  WebhookRequestTests.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 20/4/25.
//


import XCTest
@testable import n8n_workflows_ios

final class WebhookRequestTests: XCTestCase {
    func testWebhookEndpointPath() {
        let endpoint = WebhookRequest.Endpoint.webhook(path: "example-path", isTest: false)
        XCTAssertEqual(endpoint.path, "/webhook/example-path", "The non-test webhook path is incorrect.")
        
        let testEndpoint = WebhookRequest.Endpoint.webhook(path: "example-path", isTest: true)
        XCTAssertEqual(testEndpoint.path, "/webhook-test/example-path", "The test webhook path is incorrect.")
    }
}
