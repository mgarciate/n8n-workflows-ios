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
                        description: "",
                        systemImage: "figure.run"
                    )
                } else {
                    content
                }
            }
            .navigationTitle(viewModel.workflow.name)
            .onAppear() {
                print("WorkflowExecutionsView onAppear")
                fetchDataTask()
            }
        }
    }
    
    var content: some View {
        List(viewModel.executions) { execution in
            ExecutionItemView(execution: execution)
        }
        .disabled(viewModel.isLoading)
        .refreshable {
            fetchDataTask()
        }
        .scrollContentBackground(.hidden)
    }
    
    private func fetchDataTask() {
        print("fetchDataTask")
        Task {
            await viewModel.fetchData()
        }
    }
}

#Preview {
    let workflow = Workflow.dummyWorkflows[0]
    WorkflowExecutionsView(viewModel: MockWorkflowExecutionsViewModel(workflow: workflow))
}
