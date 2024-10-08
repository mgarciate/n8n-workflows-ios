//
//  WorkflowExecutionsView.swift
//  Watchflows Watch App
//
//  Created by mgarciate on 8/10/24.
//

import SwiftUI

struct WorkflowExecutionsView<ViewModel>: View where ViewModel: WorkflowExecutionsViewProtocol {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            if viewModel.executions.isEmpty {
                ContentUnavailableView("No executions",
                                       systemImage: "figure.run")
            } else {
                List(viewModel.executions) { execution in
                    ExecutionItemView(execution: execution)
                }
                .disabled(viewModel.isLoading)
                .refreshable {
                    fetchDataTask()
                }
            }
        }
        .navigationTitle("Executions")
        .onAppear() {
            fetchDataTask()
        }
    }
    
    private func fetchDataTask() {
        print("fetchDataTask")
        Task {
            await viewModel.fetchData()
        }
    }
}

#Preview {
    WorkflowExecutionsView(viewModel: MockWorkflowExecutionsViewModel(workflow: Workflow.dummyWorkflows[0]))
        .environment(WorkflowRouter())
}
