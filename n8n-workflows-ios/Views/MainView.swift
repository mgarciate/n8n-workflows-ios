//
//  MainView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 12/9/24.
//

import SwiftUI

struct ActionButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .padding(10)
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
                .background(Color.black)
                .cornerRadius(25)
        }
    }
}

struct MainView<ViewModel>: View where ViewModel: MainViewModelProtocol {
    @StateObject var viewModel: ViewModel
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 20) {
                HStack {
                    Text("Workflows")
                        .font(Font.title.bold())
                    Spacer()
                    HStack {
                        ActionButton(systemName: "gearshape") {
                            print("Action")
                        }
                    }
                }
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
            }
        }
        .padding()
//        .sheet(item: $actionSheet) { item in
//        }
//        .alert(isPresented: $viewModel.isMigrationAlertPresented) {
//        }
    }
}

#Preview {
    MainView(viewModel: MockMainViewModel())
}
