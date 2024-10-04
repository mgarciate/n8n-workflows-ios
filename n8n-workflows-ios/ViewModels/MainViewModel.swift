//
//  MainViewModel.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 13/9/24.
//

import SwiftUI



final class MainViewModel: MainViewModelProtocol {
    @Published var isLoading: Bool = true
    @Published var workflows: [Workflow] = []
    @Published var tags: [SelectableTag] = []
    @Published var isAlertPresented: Bool = false
    @Published var isOnboardingPresented: Bool = false
    @Published var apiResult: Result<WebhookResponse, ApiError>?
    var shouldShowSettings: Bool {
        guard let url = UserDefaults.standard.string(forKey: "host-url"),
              !url.isEmpty,
              let apiKey = KeychainHelper.shared.retrieveApiKey(service: KeychainHelper.service, account: KeychainHelper.account),
              !apiKey.isEmpty else {
            return true
        }
        return false
    }
    
    init() {}
    
    private func fetchTags() async {
        let selectedTagIds = tags.filter { $0.isSelected }.map { $0.tag.id }
        do {
            let response: DataResponse<Tag> = try await WorkflowApiRequest().get(endpoint: .tags)
            await MainActor.run {
                tags = response.data.map { tag in
                    SelectableTag(tag: tag, isSelected: selectedTagIds.contains(tag.id))
                }
            }
        } catch {
#if DEBUG
            print("Error", error)
#endif
        }
    }
    
    private func fetchWorkflows() async {
        do {
            var params: [String: Any] = [:]
            let selectedTagsName = tags.filter { $0.isSelected }.map { $0.tag.name }
            if !selectedTagsName.isEmpty {
                params = ["tags": selectedTagsName.joined(separator: ",")]
            }
            let response: DataResponse<Workflow> = try await WorkflowApiRequest().get(endpoint: .workflows, params: params)
            let onboardingDisplayed = UserDefaults.standard.bool(forKey: "onboarding-displayed")
            await MainActor.run {
                if !response.data.isEmpty, !onboardingDisplayed {
                    isOnboardingPresented = true
                    UserDefaults.standard.set(true, forKey: "onboarding-displayed")
                }
                workflows = response.data
            }
        } catch {
#if DEBUG
            print("Error", error)
#endif
            await MainActor.run {
                workflows = []
                isAlertPresented = true
                apiResult = .failure(error as? ApiError ?? .error(details: ResponseFailed(code: nil, message: error.localizedDescription, hint: nil)))
            }
        }
    }
    
    func fetchData() async {
        await isLoading(true)
        await fetchTags()
        await fetchWorkflows()
        await isLoading(false)
    }
    
    func toggleWorkflowActive(id: String, isActive: Bool) async {
        await isLoading(true)
        let actionType: WorkflowActionType = isActive ? .activate : .deactivate
        do {
            let updatedWorkflow: Workflow = try await WorkflowApiRequest().post(endpoint: .workflowAction(id: id, actionType: actionType))
            if let index = workflows.firstIndex(where: { $0.id == id }) {
                await MainActor.run {
                    workflows[index] = updatedWorkflow
                }
            }
        } catch {
#if DEBUG
            print("Error", error)
#endif
            guard let error = error as? ApiError else { return }
            await MainActor.run {
                isAlertPresented = true
                apiResult = .failure(error)
            }
        }
        
        await isLoading(false)
    }
    
    func toggleTag(id: String) async {
        if let index = tags.firstIndex(where: { $0.id == id }) {
            await MainActor.run {
                tags[index].isSelected.toggle()
            }
            await fetchData()
        }
    }
    
    private func isLoading(_ isLoading: Bool) async {
        await MainActor.run {
            if isLoading { isAlertPresented = false }
            self.isLoading = isLoading
        }
    }
}
