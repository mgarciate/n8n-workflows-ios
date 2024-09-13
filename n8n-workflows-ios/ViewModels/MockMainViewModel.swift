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
    
    func fetchData() async {
        workflows = Workflow.dummyWorkflows
    }
    
    func toggleWorkflowActive(id: String, isActive: Bool) {
        if let index = workflows.firstIndex(where: { $0.id == id }) {
            let updatedWorkflow = Workflow(id: workflows[index].id, name: workflows[index].name, active: isActive)
            workflows[index] = updatedWorkflow
        }
    }
}
