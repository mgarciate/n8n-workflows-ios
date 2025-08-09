//
//  JWTManagerTests.swift
//  n8n-workflows-iosTests
//
//  Created by mgarciate on 26/7/25.
//

import XCTest

final class JWTManagerTests: XCTestCase {
    
    let date = Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 27, hour: 0, minute: 0, second: 0))!

    func testCreateJWTTokenHS256() throws {
        let payload: [String : Any] = [
            "iat": Int(date.timeIntervalSince1970)
        ]
        let jwtToken = JWTManager.generateToken(payload: payload, secret: "a-string-secret-at-least-256-bits-long", algorithm: .HS256)
        XCTAssertEqual(jwtToken, "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE3NTM1NjcyMDB9.sYISHpeuIdbMcKSiMUkNt_gTx8-nKLcgzRQl9qCavxI")
    }
    
    func testCreateJWTTokenHS384() throws {
        let payload: [String : Any] = [
            "iat": Int(date.timeIntervalSince1970)
        ]
        let jwtToken = JWTManager.generateToken(payload: payload, secret: "a-string-secret-at-least-256-bits-long", algorithm: .HS384)
        XCTAssertEqual(jwtToken, "eyJhbGciOiJIUzM4NCIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE3NTM1NjcyMDB9.rLrcJL4fcHOTjtf-kJG0PCB1KuVqwFWBiAQMwzIOUNV4YVmxRzNdAlHv_oecr96A")
    }
    
    func testCreateJWTTokenHS512() throws {
        let payload: [String : Any] = [
            "iat": Int(date.timeIntervalSince1970)
        ]
        let jwtToken = JWTManager.generateToken(payload: payload, secret: "a-string-secret-at-least-256-bits-long", algorithm: .HS512)
        XCTAssertEqual(jwtToken, "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE3NTM1NjcyMDB9.XtDq4FH7OHj0J6PJQZtAX5cXnoreDvQtAcBKSO3qR-BJg7ZdY-edilwnTdhQQI0MAAw050wIvQpenL07osTYDA")
    }
}
