//
//  MainViewModel.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 13/9/24.
//

import SwiftUI

final class MainViewModel: MainViewModelProtocol {
    var userDefaults: UserDefaults
    @Published var isLoading: Bool = true
    @Published var workflows: [Workflow] = []
    @Published var tags: [SelectableTag] = []
    @Published var projects: [Project] = []
    @Published var selectedProjectId: String = Project.allProjectsId // All project by default
    @Published var isAlertPresented: Bool = false
    @Published var isOnboardingPresented: Bool = false
    @Published var apiResult: Result<WebhookResponse, ApiError>?
    var shouldShowSettings: Bool {
        guard let url = UserDefaultsHelper.shared.hostUrl,
              !url.isEmpty,
              let apiKey = KeychainHelper.shared.retrieveApiKey(service: KeychainHelper.service, account: KeychainHelper.account),
              !apiKey.isEmpty else {
            return true
        }
        return false
    }
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    private func fetchProjects() async {
        do {
            MyLogger.shared.info("MainViewModel fetchProjects")
            let response: DataResponse<Project> = try await WorkflowApiRequest().get(endpoint: .projects)
            let teamProjects = response.data.filter { $0.type == .team }
            await MainActor.run {
                guard !teamProjects.isEmpty else {
                    projects = []
                    return
                }
                projects = [Project.allProjectsObject]
                projects.append(contentsOf: teamProjects)
            }
        } catch {
            MyLogger.shared.error("MainViewModel fetchProjects error \(error, privacy: .public)")
#if DEBUG
            print("Error", error)
#endif
        }
        await MainActor.run {
            projects = []
        }
    }
    
    private func fetchTags() async {
        MyLogger.shared.info("MainViewModel fetchTags")
        let selectedTagIds = tags.filter { $0.isSelected }.map { $0.tag.id }
        do {
            let response: DataResponse<Tag> = try await WorkflowApiRequest().get(endpoint: .tags)
            await MainActor.run {
                tags = response.data.map { tag in
                    SelectableTag(tag: tag, isSelected: selectedTagIds.contains(tag.id))
                }
            }
        } catch {
            MyLogger.shared.error("MainViewModel fetchTags error \(error, privacy: .public)")
#if DEBUG
            print("Error", error)
#endif
        }
    }
    
    func sortWorkflows(_ workflows: [Workflow]) -> [Workflow] {
        let sortOption: WorkflowSortOption = userDefaults.string(forKey: "sort")
            .flatMap(WorkflowSortOption.init) ?? WorkflowSortOption.defaultValue
        let sortOrder: SortOrder = userDefaults.string(forKey: "order")
            .flatMap(SortOrder.init) ?? SortOrder.defaultValue
        return switch sortOption {
        case .name: workflows.sortedByLocalizedString(\.name, ascending: sortOrder == .ascending)
        case .createdAt: workflows.sortedByDateString(\.createdAt, ascending: sortOrder == .ascending)
        case .updatedAt: workflows.sortedByDateString(\.updatedAt, ascending: sortOrder == .ascending)
        }
    }
    
    private func fetchWorkflows() async {
        do {
            MyLogger.shared.info("MainViewModel fetchWorkflows")
            var params: [String: Any] = [:]
            let selectedTagsName = tags.filter { $0.isSelected }.map { $0.tag.name }
            if !selectedTagsName.isEmpty {
                params["tags"] = selectedTagsName.joined(separator: ",")
            }
            if !selectedProjectId.isEmpty {
                params["projectId"] = selectedProjectId
            }
            let response: DataResponse<Workflow> = try await WorkflowApiRequest().get(endpoint: .workflows, params: params)
            let onboardingDisplayed = UserDefaultsHelper.shared.onboardingDisplayed
            await MainActor.run {
                if !response.data.isEmpty, !onboardingDisplayed {
                    isOnboardingPresented = true
                    UserDefaultsHelper.shared.onboardingDisplayed = true
                }
                workflows = sortWorkflows(response.data)
            }
        } catch {
            MyLogger.shared.error("MainViewModel fetchWorkflows error \(error, privacy: .public)")
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
        MyLogger.shared.info("MainViewModel fetchData")
        await isLoading(true)
        await fetchProjects()
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
    
    func toggleProject(id: String) async {
        await fetchData()
    }
    
    private func isLoading(_ isLoading: Bool) async {
        await MainActor.run {
            if isLoading { isAlertPresented = false }
            self.isLoading = isLoading
        }
    }
}
