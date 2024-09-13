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
        List(viewModel.executions) { execution in
            Text(execution.id)
        }
        .onAppear() {
            Task {
                await viewModel.fetchData()
            }
        }
        .navigationTitle(viewModel.workflow.name)
    }
}

#Preview {
    WorkflowExecutionsView(viewModel: MockWorkflowExecutionsViewModel(workflow: Workflow.dummyWorkflows[0]))
}
