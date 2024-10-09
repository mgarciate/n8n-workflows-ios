//
//  ExecutionItemView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 9/10/24.
//


import SwiftUI

struct ExecutionItemView: View {
    let execution: Execution
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("#\(execution.id)")
                    .font(.title3.bold())
                Spacer()
            }
            Text(execution.startedAt.date?.dateString ?? "-")
                .fontWeight(.bold)
            HStack(alignment: .bottom, spacing: 5) {
                if execution.finished {
                    Text("✅")
                        .foregroundStyle(Color("Green"))
                        .fontWeight(.bold)
                } else {
                    Text("❌")
                        .foregroundStyle(Color("Red"))
                        .fontWeight(.bold)
                }
                if let executionTimeInSeconds = execution.executionTimeInSeconds {
                    Text("\(String(format: "%.3f", executionTimeInSeconds))s")
                        .fontWeight(.bold)
                }
            }
        }
        .font(.caption2)
    }
}

#Preview {
    ExecutionItemView(execution: Execution.dummyExecutions[0])
}
