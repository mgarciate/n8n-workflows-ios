//
//  MockWorkflowExecutionsViewModel.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 13/9/24.
//


import SwiftUI

final class MockWorkflowExecutionsViewModel: WorkflowExecutionsViewProtocol {
    var workflow: Workflow
    @Published var executions: [Execution] = []
    
    init(workflow: Workflow) {
        self.workflow = workflow
    }
    
    func fetchData() async {
        executions = Execution.dummyExecutions
    }
}
