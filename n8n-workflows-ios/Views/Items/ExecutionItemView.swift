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
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.6, green: 0.65, blue: 0.7))
                .shadow(radius: 5)
            VStack(alignment: .leading) {
                HStack {
                    Text("#\(execution.id)")
                        .fontWeight(.bold)
                    Spacer()
                }
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
            .padding(.horizontal)
        }
        .foregroundStyle(.white)
    }
}

#Preview {
    List(Execution.dummyExecutions) { execution in
        ExecutionItemView(execution: execution)
    }
}
