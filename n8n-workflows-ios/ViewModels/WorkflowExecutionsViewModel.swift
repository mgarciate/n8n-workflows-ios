//
//  WorkflowExecutionsViewModel.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 13/9/24.
//

import SwiftUI

final class WorkflowExecutionsViewModel: WorkflowExecutionsViewProtocol {
    var workflow: Workflow
    @Published var executions: [Execution] = []
    
    init(workflow: Workflow) {
        self.workflow = workflow
    }
    
    func fetchData() async {
        do {
            let executions = try await NetworkService<DataResponse<Execution>>().get(endpoint: "executions", params: ["workflowId": workflow.id]).data
            await MainActor.run {
                self.executions = executions
            }
        } catch {
#if DEBUG
            print("Error", error)
#endif
        }
    }
}
