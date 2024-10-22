//
//  MockMainViewModel.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 13/9/24.
//


import SwiftUI

final class MockMainViewModel: MainViewModelProtocol {
    @Published var isLoading: Bool = false
    @Published var workflows: [Workflow] = []
    @Published var tags: [SelectableTag] = {
        (1...5).map { SelectableTag(tag: Tag(id: "tagId\($0)", name: "tagName\($0)"), isSelected: $0 == 2) }
    }()
    @Published var projects: [Project] = {
        var projects = [Project.allProjectsObject]
        projects.append(contentsOf: (1...5).map { Project(id: "projectId\($0)", name: "projectName\($0)", type: .team) } )
        return projects
    }()
    @Published var selectedProjectId: String = Project.allProjectsId
    @Published var isAlertPresented: Bool = false
    @Published var isOnboardingPresented: Bool = false
    @Published var apiResult: Result<WebhookResponse, ApiError>?
    var shouldShowSettings: Bool = false
    
    func fetchData() async {
        workflows = Workflow.dummyWorkflows
    }
    
    func toggleWorkflowActive(id: String, isActive: Bool) {
        if let index = workflows.firstIndex(where: { $0.id == id }) {
            let updatedWorkflow = Workflow(id: workflows[index].id, name: workflows[index].name, active: isActive, createdAt: workflows[index].createdAt, updatedAt: workflows[index].updatedAt, nodes: workflows[index].nodes)
            workflows[index] = updatedWorkflow
        }
    }
    
    func toggleTag(id: String) async {
        if let index = tags.firstIndex(where: { $0.id == id }) {
            tags[index].isSelected.toggle()
        }
    }
    
    func toggleProject(id: String) async {}
}
