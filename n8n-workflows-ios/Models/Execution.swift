//
//  Execution.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 12/9/24.
//

import Foundation

struct Execution: Codable, Identifiable {
    let id: String
    let finished: Bool
    let startedAt: String
    let stoppedAt: String
}

extension Execution {
    static private func format(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.string(from: date)
    }
    static var dummyExecutions: [Execution] {
        var date = "2024-09-20T21:11:58.094Z".date ?? Date.now
        return (1...10).map {
            let finished = ($0 % 3) != 0
            let startDate = date
            let stoppedDate = date.addingTimeInterval(Double($0) / 10 + 0.155) // add $0/10 + 0.155 seconds
            date.addTimeInterval(3600) // add 1 hour
            return Execution(id: "\($0)", finished: finished, startedAt: format(date: startDate), stoppedAt: format(date: stoppedDate))
        }
    }
}

extension Execution {
    var executionTimeInSeconds: Double? {
        guard let startDate = startedAt.date,
              let stoppedDate = stoppedAt.date else { return nil }
        return stoppedDate.timeIntervalSince(startDate)
    }
}
