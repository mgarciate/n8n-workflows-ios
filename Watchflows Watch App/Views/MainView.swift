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
        ZStack {
            if !viewModel.isLoading, viewModel.workflows.isEmpty {
                ContentUnavailableView("No workflows",
                                       systemImage: "flowchart",
                                       description: Text("Create workflows or configure you n8n instance in your iPhone")
                )
            } else {
                content
            }
            if viewModel.isLoading {
                ZStack {
                    Color.clear
                    ZStack {
                        ProgressView("Loading n8n data...")
                            .tint(.white)
                            .foregroundStyle(.white)
                            .controlSize(.large)
                            .padding()
                            .background(.black.opacity(0.7))
                    }
                }
                .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                .allowsHitTesting(!viewModel.isLoading)
            }
        }
        .alert(isPresented: $viewModel.isAlertPresented) {
            switch viewModel.apiResult {
            case .success(let response):
                Alert(title: Text(""),
                      message: Text(response.message),
                      dismissButton: .default(Text("OK")) {
                    // do nothing
                }
                )
            case .failure(let error):
                Alert(title: Text(error.title),
                      message: Text(error.message),
                      dismissButton: .cancel() {
//                    do nothing
                }
                )
            case .none:
                Alert(title: Text("Unknown"),
                      message: Text(""),
                      dismissButton: .default(Text("OK")) {
                    // do nothing
                }
                )
            }
        }
        .onAppear() {
            fetchDataTask()
        }
    }
        
    var content: some View {
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
