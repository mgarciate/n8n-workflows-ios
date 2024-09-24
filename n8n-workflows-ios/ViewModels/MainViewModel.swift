//
//  MainViewModel.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 13/9/24.
//

import SwiftUI

final class MainViewModel: MainViewModelProtocol {
    @Published var isLoading: Bool = false
    @Published var workflows: [Workflow] = []
    
    init() {}
    
    func fetchData() async {
        await isLoading(true)
        do {
            let response: DataResponse<Workflow> = try await WorkflowApiRequest().get(endpoint: .workflows)
            await MainActor.run {
                self.workflows = response.data
            }
        } catch {
#if DEBUG
            print("Error", error)
#endif
        }
        await isLoading(false)
    }
    
    func toggleWorkflowActive(id: String, isActive: Bool) async {
        await isLoading(true)
        let actionType: WorkflowActionType = isActive ? .activate : .deactivate
        do {
            let updatedWorkflow: Workflow = try await WorkflowApiRequest().get(endpoint: .workflowAction(id: id, actionType: actionType))
            if let index = workflows.firstIndex(where: { $0.id == id }) {
                await MainActor.run {
                    workflows[index] = updatedWorkflow
                }
            }
        } catch {
#if DEBUG
            print("Error", error)
#endif
        }
        await isLoading(false)
    }
    
    private func isLoading(_ isLoading: Bool) async {
        await MainActor.run {
            self.isLoading = isLoading
        }
    }
}
