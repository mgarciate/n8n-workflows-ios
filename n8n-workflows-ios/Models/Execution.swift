//
//  Execution.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 12/9/24.
//

struct Execution: Codable, Identifiable {
    let id: String
    let finished: Bool
    let startedAt: String
    let stoppedAt: String
}

extension Execution {
    static let dummyExecutions = (1...10).map {
        return Execution(id: "id\($0)", finished: true, startedAt: "", stoppedAt: "")
    }
}
