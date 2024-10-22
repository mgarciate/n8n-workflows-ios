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
        .navigationTitle("Executions")
        .onAppear() {
            print("WorkflowExecutionsView onAppear")
            fetchDataTask()
        }
    }
    
    var content: some View {
        List(viewModel.executions) { execution in
            ExecutionItemView(execution: execution)
                .listRowSeparator(.hidden)
        }
        .padding(.horizontal, -20)
        .disabled(viewModel.isLoading)
        .refreshable {
            fetchDataTask()
        }
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    Text("")
                    NavigationLink {
                        ChartsView(viewModel: ChartsViewModel(workflows: [viewModel.workflow]))
                    } label: {
                        Image(systemName: "chart.xyaxis.line")
                    }
                }
            }
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
    let workflow = Workflow.dummyWorkflows[0]
    NavigationStack {
        WorkflowExecutionsView(viewModel: MockWorkflowExecutionsViewModel(workflow: workflow))
    }
}
