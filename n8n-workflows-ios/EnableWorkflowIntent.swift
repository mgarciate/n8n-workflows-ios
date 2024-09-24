//
//  EnableWorkflowIntent.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 15/9/24.
//

import AppIntents

struct EnableWorkflowIntent: AppIntent {
    
    static var title = LocalizedStringResource("Activate workflow")
    static var description: IntentDescription? = "Reactivates a previously disabled workflow, allowing it to run again based on defined triggers and events."
    
    @Parameter(title: "Select a Workflow")
    var workflow: Workflow
    
    func perform() async throws -> some IntentResult {
        let actionType: WorkflowActionType = .activate
        let _: Workflow = try await WorkflowApiRequest().get(endpoint: .workflowAction(id: workflow.id, actionType: actionType))
        return .result()
    }
}


