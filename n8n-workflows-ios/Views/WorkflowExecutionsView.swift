//
//  WorkflowExecutionsView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 12/9/24.
//

import SwiftUI

struct WorkflowExecutionsView<ViewModel>: View where ViewModel: WorkflowExecutionsViewProtocol {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.executions.isEmpty {
                    ContentUnavailableCompatView(
                        title: "No executions",
                        description: "figure.run",
                        systemImage: "description aksldñjf klñasdjfñlasdj flñadskj flsadkj fsadkl"
                    )
                } else {
                    content
                }
            }
            .navigationTitle(viewModel.workflow.name)
            .onAppear() {
                print("WorkflowExecutionsView onAppear")
                Task {
                    await viewModel.fetchData()
                }
            }
        }
    }
    
    var content: some View {
        List(viewModel.executions) { execution in
            Text(execution.id)
        }
    }
}

#Preview {
    let workflow = Workflow.dummyWorkflows[0]
    WorkflowExecutionsView(viewModel: MockWorkflowExecutionsViewModel(workflow: workflow))
}
