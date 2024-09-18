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
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var viewModel: ViewModel
    @State private var showSettings = false
    @State private var isInactiveOrBackground = false
    
    var body: some View {
        NavigationStack {
            List(viewModel.workflows) { workflow in
                NavigationLink {
                    WorkflowExecutionsView(viewModel: WorkflowExecutionsViewModel(workflow: workflow))
                } label: {
                    WorkflowItemView(workflow: workflow) { newValue in
                        Task {
                            await viewModel.toggleWorkflowActive(id: workflow.id, isActive: newValue)
                        }
                    }
                }
            }
            .disabled(viewModel.isLoading)
            .refreshable {
                fetchDataTask()
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Workflows")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showSettings, onDismiss: {
            fetchDataTask()
        }) {
            SettingsView(viewModel: SettingsViewModel())
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
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .inactive, .background:
                isInactiveOrBackground = true
            case .active:
                guard isInactiveOrBackground else { return }
                isInactiveOrBackground = false
                fetchDataTask()
            @unknown default:
#if DEBUG
                print("do nothing")
#endif
            }
        }
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
    MainView(viewModel: MockMainViewModel())
}
