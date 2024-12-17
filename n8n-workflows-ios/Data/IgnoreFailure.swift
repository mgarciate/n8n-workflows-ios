//
//  IgnoreFailure.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 17/12/24.
//

import OSLog

public class MyLogger {
    static let shared = Logger(subsystem: "com.mgarciate.n8n-workflows", category: "debugging")

    private init() { }
}

@propertyWrapper
struct IgnoreFailure<Value: Codable>: Codable {
    var wrappedValue: [Value] = []

    private struct _None: Decodable {}

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        while !container.isAtEnd {
            if let decoded = try? container.decode(Value.self) {
                wrappedValue.append(decoded)
            }
            else {
                // Ignored
                _ = try? container.decode(_None.self)
            }
        }
    }
}
