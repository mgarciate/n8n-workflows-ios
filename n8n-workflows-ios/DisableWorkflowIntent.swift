//
//  DisableWorkflowIntent.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 16/9/24.
//

import AppIntents

struct DisableWorkflowIntent: AppIntent {
    
    static var title = LocalizedStringResource("Deactivate workflow ")
    static var description: IntentDescription? = "Disables a workflow to prevent it from running during specific events or conditions."
    
    @Parameter(title: "Select a Workflow")
    var workflow: Workflow
    
    func perform() async throws -> some IntentResult {
        let actionType: WorkflowActionType = .deactivate
        let _ = try await NetworkService<Workflow>().post(endpoint: "workflows/\(workflow.id)/\(actionType)", body: [:])
        return .result()
    }
}
