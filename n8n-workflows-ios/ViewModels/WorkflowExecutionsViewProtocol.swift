//
//  WorkflowExecutionsViewProtocol.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 13/9/24.
//

import SwiftUI

protocol WorkflowExecutionsViewProtocol: ObservableObject {
    var workflow: Workflow { get }
    var executions: [Execution] { get set }

    func fetchData() async
}
