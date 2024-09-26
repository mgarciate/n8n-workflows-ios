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
    @Published var isAlertPresented: Bool = false
    @Published var apiResult: Result<WebhookResponse, ApiError>?
    
    init() {}
    
    func fetchData() async {
        await isLoading(true)
        do {
            let response: DataResponse<Workflow> = try await WorkflowApiRequest().get(endpoint: .workflows)
            await MainActor.run {
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
    
    private func isLoading(_ isLoading: Bool) async {
        await MainActor.run {
            self.isLoading = isLoading
        }
    }
}
