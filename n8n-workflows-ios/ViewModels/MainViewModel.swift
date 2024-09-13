//
//  MainViewModel.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 13/9/24.
//

import SwiftUI

final class MainViewModel: MainViewModelProtocol {
    @Published var workflows: [Workflow] = []
    
    init() {}
    
    func fetchData() async {
        do {
            let workflows = try await NetworkService<DataResponse<Workflow>>().get(endpoint: "workflows").data
            await MainActor.run {
                self.workflows = workflows
            }
        } catch {
#if DEBUG
            print("Error", error)
#endif
        }
    }
    
    func toggleWorkflowActive(id: String, isActive: Bool) {
        if let index = workflows.firstIndex(where: { $0.id == id }) {
            let updatedWorkflow = Workflow(id: workflows[index].id, name: workflows[index].name, active: isActive)
            workflows[index] = updatedWorkflow
        }
    }
}
