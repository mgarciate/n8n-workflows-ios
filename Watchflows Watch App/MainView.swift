//
//  MainView.swift
//  Watchflows Watch App
//
//  Created by mgarciate on 8/10/24.
//

import SwiftUI

struct MainView<ViewModel>: View where ViewModel: MainViewModelProtocol {
    @Environment(WorkflowRouter.self) var router
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        //            ContentUnavailableView("No workflows",
        //                                   systemImage: "flowchart",
        //                                   description: Text("Create workflows or configure you n8n instance in your iPhone"))
        
        List(viewModel.workflows) { workflow in
            VStack {
                Toggle(workflow.name, isOn: Binding(
                    get: { workflow.active },
                    set: { newValue in
                        Task {
                            await viewModel.toggleWorkflowActive(id: workflow.id, isActive: newValue)
                        }
                    }
                ))
                .onTapGesture {
                    Task {
                        await viewModel.toggleWorkflowActive(id: workflow.id, isActive: !workflow.active)
                    }
                }
                HStack {
                    if !workflow.webhooks.isEmpty {
                        Button("", systemImage: "paperplane") {
                            router.navigateTo(route: .webhooks(workflow: workflow))
                        }
                        .labelsHidden()
                        .buttonStyle(.borderedProminent)
                    }
                    Button("", systemImage: "figure.run") {
                        router.navigateTo(route: .executions(workflow: workflow))
                    }
                    .labelsHidden()
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("Workflows")
        .disabled(viewModel.isLoading)
        .refreshable {
            fetchDataTask(showLoading: false)
        }
        .onAppear() {
            fetchDataTask()
        }
    }
    
    private func fetchDataTask(showLoading: Bool = true) {
        print("fetchDataTask")
        Task {
            await viewModel.fetchData()
        }
    }
}

#Preview {
    MainView(viewModel: MockMainViewModel())
        .environment(WorkflowRouter())
}
