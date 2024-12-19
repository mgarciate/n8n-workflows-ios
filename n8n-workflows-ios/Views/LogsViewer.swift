//
//  LogsViewer.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 17/12/24.
//

import OSLog
import SwiftUI

struct LogsViewer: View {
    @Environment(\.dismiss) private var dismiss
    @State var logs: [OSLogEntryLog]
    @State private var logFileURL: URL?

    init() {
        let logStore = try! OSLogStore(scope: .currentProcessIdentifier)
        self.logs = try! logStore.getEntries().compactMap { entry in
            guard let logEntry = entry as? OSLogEntryLog,
                  logEntry.subsystem.starts(with: "com.mgarciate.n8n-workflows") == true else {
                return nil
            }

            return logEntry
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                List(logs, id: \.self) { log in
                    VStack(alignment: .leading) {
                        Text(log.composedMessage)
                        HStack {
                            Text("\(log.composedMessage.count)")
                            Text(log.date, format: .dateTime)
                        }.bold()
                    }
                }
                .listStyle(.plain)
                
                if let logFileURL = logFileURL {
                    ShareLink(item: logFileURL, preview: SharePreview("Logs File", image: Image(systemName: "doc.text"))) {
                        Label("Share Logs", systemImage: "square.and.arrow.up")
                    }
                } else {
                    Button(action: generateLogFile) {
                        Label("Generate Log File", systemImage: "doc.badge.plus")
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
    
    private func generateLogFile() {
        let logMessages = logs.map { log in
            "\(log.date): [\(log.level.rawValue)] [\(log.subsystem)] \(log.composedMessage)"
        }.joined(separator: "\n")
        
        let fileName = "logs.txt"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try logMessages.write(to: fileURL, atomically: true, encoding: .utf8)
            logFileURL = fileURL
        } catch {
            print("Error creating log file: \(error)")
        }
    }
}

#Preview {
    LogsViewer()
}
