//
//  MainView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 12/9/24.
//

import SwiftUI







struct MainView<ViewModel>: View where ViewModel: MainViewModelProtocol {
    @StateObject var viewModel: ViewModel
    var body: some View {
        List(viewModel.workflows) { workflow in
            NavigationLink(destination: WorkflowExecutionsView(viewModel: WorkflowExecutionsViewModel(workflow: workflow))) {
                Toggle(workflow.name, isOn: Binding(
                    get: { workflow.active },
                    set: { newValue in
                        viewModel.toggleWorkflowActive(id: workflow.id, isActive: newValue)
                    }
                ))
            }
        }
        .onAppear() {
            Task {
                await viewModel.fetchData()
            }
        }
        .navigationTitle("Workflows")
    }
}

#Preview {
    NavigationView {
        MainView(viewModel: MockMainViewModel())
    }
    .navigationTitle("Workflows")
}
