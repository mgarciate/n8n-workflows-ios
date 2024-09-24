//
//  WorkflowExecutionsViewModel.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 13/9/24.
//

import SwiftUI

final class WorkflowExecutionsViewModel: WorkflowExecutionsViewProtocol {
    var workflow: Workflow
    @Published var isLoading: Bool = false
    @Published var executions: [Execution] = []
    
    init(workflow: Workflow) {
        self.workflow = workflow
    }
    
    func fetchData() async {
        await isLoading(true)
        do {
            let response: DataResponse<Execution> = try await WorkflowApiRequest().get(endpoint: .executions, params: ["workflowId": workflow.id])
            await MainActor.run {
                self.executions = response.data
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
