//
//  MainView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 12/9/24.
//

import SwiftUI

enum MainActionSheet: Hashable, Identifiable {
    case settings
    case executions(workflow: Workflow)
    
    var id: Self {
        return self
    }
}

struct MainView<ViewModel>: View where ViewModel: MainViewModelProtocol {
    @StateObject var viewModel: ViewModel
    @State var actionSheet: MainActionSheet?
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 20) {
                HStack {
                    Text("Workflows")
                        .font(Font.title.bold())
                    Spacer()
                    HStack {
                        ActionButton(systemName: "gearshape") {
                            actionSheet = .settings
                        }
                    }
                }
                .padding(.horizontal)
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
                        HStack {
                            Text(workflow.createdAt)
                            Text(workflow.updatedAt)
                            Spacer()
                        }
                        .foregroundStyle(Color("Gray"))
                        .font(.caption.italic())
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
                    .onTapGesture {
                        actionSheet = .executions(workflow: workflow)
                    }
                }
                .disabled(viewModel.isLoading)
                .refreshable {
                    Task {
                        await viewModel.fetchData()
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .sheet(item: $actionSheet) { item in
            switch(item) {
            case .settings:
                SettingsView(actionSheet: $actionSheet)
            case .executions(let workflow):
                WorkflowExecutionsView(viewModel: WorkflowExecutionsViewModel(workflow: workflow), actionSheet: $actionSheet)
            }
        }
//        .alert(isPresented: $viewModel.isMigrationAlertPresented) {
//            Alert(title: Text(Resources.Strings.Common.appName),
//                  message: Text(Resources.Strings.Migration.v150.message),
//                  primaryButton: .cancel(),
//                  secondaryButton: .destructive(Text(Resources.Strings.Common.signOut)) {
//                viewModel.signOut()
//            }
//            )
//        }

        .onAppear() {
            print("MainView onAppear")
            Task {
                await viewModel.fetchData()
            }
        }
    }
}

#Preview {
    MainView(viewModel: MockMainViewModel())
}
