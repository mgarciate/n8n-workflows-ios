//
//  MyLogger.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 19/12/24.
//

import OSLog

public class MyLogger {
    static let shared = Logger(subsystem: "com.mgarciate.n8n-workflows", category: "debugging")

    private init() { }
}
