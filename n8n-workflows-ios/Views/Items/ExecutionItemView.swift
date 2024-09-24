//
//  ExecutionItemView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 20/9/24.
//

import SwiftUI

struct ExecutionItemView: View {
    let execution: Execution
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("#\(execution.id)")
                .fontWeight(.bold)
            HStack(alignment: .bottom, spacing: 5) {
                Text("Executed at")
                    .font(.caption.italic())
                Text(execution.startedAt.date?.dateString ?? "-")
                    .font(.subheadline.bold())
            }
            HStack(alignment: .bottom, spacing: 5) {
                if execution.finished {
                    Text("Succeeded in")
                        .foregroundStyle(Color("Green"))
                        .font(.caption.italic())
                        .fontWeight(.bold)
                } else {
                    Text("Error in")
                        .foregroundStyle(Color("Red"))
                        .font(.caption.italic())
                        .fontWeight(.bold)
                }
                if let executionTimeInSeconds = execution.executionTimeInSeconds {
                    Text("\(String(format: "%.3f", executionTimeInSeconds))s")
                        .font(.subheadline.bold())
                }
            }
        }
    }
}

#Preview {
    List(Execution.dummyExecutions) { execution in
        ExecutionItemView(execution: execution)
    }
}
