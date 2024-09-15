//
//  WorkflowExecutionsView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 12/9/24.
//

import SwiftUI

struct WorkflowExecutionsView<ViewModel>: View where ViewModel: WorkflowExecutionsViewProtocol {
    @StateObject var viewModel: ViewModel
    @Binding var actionSheet: MainActionSheet?
    var body: some View {
        VStack {
            SheetTitleView(title: viewModel.workflow.name, closeAction: {
                actionSheet = nil
            })
            List(viewModel.executions) { execution in
                Text(execution.id)
            }
        }
        .onAppear() {
            print("WorkflowExecutionsView onAppear")
            Task {
                await viewModel.fetchData()
            }
        }
    }
}

#Preview {
    let workflow = Workflow.dummyWorkflows[0]
    WorkflowExecutionsView(viewModel: MockWorkflowExecutionsViewModel(workflow: workflow), actionSheet: .constant(.executions(workflow: workflow)))
}
