//
//  MainView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 12/9/24.
//

import SwiftUI

enum MainActionSheet: Hashable, Identifiable {
    case settings
    case sort
    
    var id: Self {
        return self
    }
}

struct MainView<ViewModel>: View where ViewModel: MainViewModelProtocol {
    @Environment(\.scenePhase) var scenePhase
    @AppStorage("sort") private var selectedSortOption: WorkflowSortOption = WorkflowSortOption.defaultValue
    @AppStorage("order") private var selectedSortOrder: SortOrder = SortOrder.defaultValue
    
    @StateObject var viewModel: ViewModel
    @State var navigationPath = NavigationPath()
    @State private var actionSheet: MainActionSheet?
    @State private var infoPopoverPresented = false
    @State private var isInactiveOrBackground = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                if !viewModel.isLoading, viewModel.workflows.isEmpty {
                    ContentUnavailableCompatView(
                        title: "No workflows",
                        description: "It might be because you haven't created any workflow in n8n yet, or the host and credentials are not configured correctly. You can check and set them up using the button ⚙️ in the top right corner  ⤴.",
                        systemImage: "flowchart"
                    )
                } else {
                    
                }
                content
                if viewModel.isLoading {
                    LoadingView(isLoading: viewModel.isLoading)
                }
            }
            .navigationTitle("n-eight-n Workflows")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        actionSheet = .settings
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
                ToolbarItem(placement: .automatic) {
                    HStack {
                        Text("")
                        NavigationLink {
                            ChartsView(viewModel: ChartsViewModel(workflows: viewModel.workflows))
                        } label: {
                            Image(systemName: "chart.xyaxis.line")
                        }
                    }
                }
            }
        }
        .fullScreenCover(item: $actionSheet, onDismiss: {
            viewModel.isLoading = true
            fetchDataTask()
        }) { item in
            switch item {
            case .settings:
                SettingsView(viewModel: SettingsViewModel())
            case .sort:
                SortView()
                    .presentationDetents([.medium, .large])
            }
        }
        .sheet(isPresented: $viewModel.isOnboardingPresented) {
            OnboardingView()
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
            Task {
                do {
                    MyLogger.shared.info("MainView onAppear")
                    let userConfig = try await UserConfigurationManager.shared.fetchSettings()
                    if let _ = userConfig.hostUrl {
                        UserDefaultsHelper.shared.saveUserConfig(userConfig)
                    }
                } catch {
#if DEBUG
                    print("Error getting CloudKit configuration: \(error.localizedDescription)")
#endif
                }
                guard !viewModel.shouldShowSettings else {
                    actionSheet = .settings
                    return
                }
                fetchDataTask()
            }
        }
    }

    var content: some View {
        List {
            if !viewModel.projects.isEmpty {
                Picker("Project", selection: $viewModel.selectedProjectId) {
                    ForEach(viewModel.projects, id: \.id) { project in
                        Text(project.name).tag(project.id as String?)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: viewModel.selectedProjectId, initial: false) { oldId, newId in
                    Task {
                        await viewModel.toggleProject(id: newId)
                    }
                }
            }
            if !viewModel.tags.isEmpty {
                HStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            Button(action: {
                                actionSheet = .sort
                            }, label: {
                                HStack(spacing: 3) {
                                    Image(systemName: "line.horizontal.3.decrease")
                                    Text(selectedSortOption.rawValue)
                                    if selectedSortOrder == .ascending {
                                        Image(systemName: "arrow.up")
                                    } else {
                                        Image(systemName: "arrow.down")
                                    }
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .font(.system(size: 14, weight: .semibold))
                            })
                            .foregroundColor(.white)
                            .background(Color("Red"))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color("Red"), lineWidth: 2)
                                    .padding(.leading, 1)
                            )
                            .frame(height: 40)
                            ForEach(viewModel.tags) { selectableTag in
                                Text(selectableTag.tag.name)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(Color("Red").opacity(selectableTag.isSelected ? 0.8 : 0.0))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(selectableTag.isSelected ? .white : Color("Black"))
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color("Red"), lineWidth: 2)
                                            .padding(.leading, 1)
                                    )
                                    .frame(height: 40)
                                    .onTapGesture {
                                        Task {
                                            await viewModel.toggleTag(id: selectableTag.id)
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            ForEach(viewModel.workflows) { workflow in
                WorkflowItemView(workflow: workflow, action: { newValue in
                    Task {
                        await viewModel.toggleWorkflowActive(id: workflow.id, isActive: newValue)
                    }
                }, launchWebhook: { webhook in
                    navigationPath.append(webhook)
                }, launchChat: { chat in
                    
                })
                .onTapGesture {
                    navigationPath.append(workflow)
                }
                .listRowSeparator(.hidden)
            }
        }
        .padding(.horizontal, -20)
        .disabled(viewModel.isLoading)
        .refreshable {
            fetchDataTask(showLoading: false)
        }
        .scrollContentBackground(.hidden)
        .navigationDestination(for: Workflow.self) { workflow in
            WorkflowExecutionsView(viewModel: WorkflowExecutionsViewModel(workflow: workflow))
        }
        .navigationDestination(for: Webhook.self) { webhook in
            LaunchWebhookView(viewModel: LaunchWebhookViewModel(webhook: webhook))
        }
        .navigationDestination(for: ChatTrigger.self) { chat in
            LaunchWebhookView(viewModel: LaunchWebhookViewModel(webhook: webhook))
        }
    }
    
    private func fetchDataTask(showLoading: Bool = true) {
        Task {
            MyLogger.shared.info("MainView fetchDataTask")
            await viewModel.fetchData()
        }
    }
}

#Preview {
    MainView(viewModel: MockMainViewModel())
}
