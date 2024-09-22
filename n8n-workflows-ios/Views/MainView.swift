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
    @State private var infoPopoverPresented = false
    @State private var isInactiveOrBackground = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.workflows.isEmpty {
                    ContentUnavailableCompatView(
                        title: "No workflows",
                        description: " description aksldñjf klñasdjfñlasdj ⚙️ ⤴  flñadskj flsadkj fsadkl",
                        systemImage: "flowchart"
                    )
                } else {
                    content
                }
            }
            .navigationTitle("Workflows")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .automatic) {
                    HStack {
                        Text("")
                        NavigationLink {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("About n8n")
                                    .font(.title.bold())
                                Text("n8n (pronounced n-eight-n) helps you to connect any app with an API with any other, and manipulate its data with little or no code.\n\n- Customizable: highly flexible workflows and the option to build custom nodes.\n- Convenient: use the npm or Docker to try out n8n, or the Cloud hosting option if you want us to handle the infrastructure.\n- Privacy-focused: self-host n8n for privacy and security.")
                                Spacer()
                            }
                            .padding()
                        } label: {
                            Image(systemName: "info.circle")
                        }
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
    
    var content: some View {
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
