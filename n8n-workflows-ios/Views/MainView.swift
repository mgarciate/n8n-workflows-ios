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
        ZStack {
            List(viewModel.workflows) { workflow in
                NavigationLink(destination: WorkflowExecutionsView(viewModel: WorkflowExecutionsViewModel(workflow: workflow))) {
                    Toggle(workflow.name, isOn: Binding(
                        get: { workflow.active },
                        set: { newValue in
                            Task {
                                await viewModel.toggleWorkflowActive(id: workflow.id, isActive: newValue)
                            }
                        }
                    ))
                }
            }
            .disabled(viewModel.isLoading)
            .refreshable {
                Task {
                    await viewModel.fetchData()
                }
            }
            .onAppear() {
                print("MainView onAppear")
                Task {
                    await viewModel.fetchData()
                }
            }
            .navigationTitle("Workflows")
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
    }
}

#Preview {
    NavigationView {
        MainView(viewModel: MockMainViewModel())
    }
    .navigationTitle("Workflows")
}
