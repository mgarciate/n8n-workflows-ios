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
    @State private var isSettingsPresented = false
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
            .navigationTitle("Workflows")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isSettingsPresented = true
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
        .fullScreenCover(isPresented: $isSettingsPresented, onDismiss: {
            viewModel.isLoading = true
            fetchDataTask()
        }) {
            SettingsView(viewModel: SettingsViewModel())
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
            guard !viewModel.shouldShowSettings else {
                isSettingsPresented = true
                return
            }
            fetchDataTask()
        }
    }

    var content: some View {
        List {
            if !viewModel.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
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
            ForEach(viewModel.workflows) { workflow in
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
}
