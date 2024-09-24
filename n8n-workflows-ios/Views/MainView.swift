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
    @State var navigationPath = NavigationPath()
    @State private var showSettings = false
    @State private var infoPopoverPresented = false
    @State private var isInactiveOrBackground = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
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
            .navigationTitle("n8n workflows")
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
                            AboutN8nView()
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
            WorkflowItemView(workflow: workflow, action: { newValue in
                Task {
                    await viewModel.toggleWorkflowActive(id: workflow.id, isActive: newValue)
                }
            }, launchWebhook: { webhook in
                navigationPath.append(webhook)
            })
            .onTapGesture {
                navigationPath.append(workflow)
            }
            .listRowSeparator(.hidden)
        }
        .padding(.horizontal, -20)
        .disabled(viewModel.isLoading)
        .refreshable {
            fetchDataTask()
        }
        .scrollContentBackground(.hidden)
        .navigationDestination(for: Workflow.self) { workflow in
            WorkflowExecutionsView(viewModel: WorkflowExecutionsViewModel(workflow: workflow))
        }
        .navigationDestination(for: Webhook.self) { webhook in
            LaunchWebhookView(viewModel: LaunchWebhookViewModel(webhook: webhook))
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
