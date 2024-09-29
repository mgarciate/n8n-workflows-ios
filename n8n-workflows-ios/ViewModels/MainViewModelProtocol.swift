//
//  MainViewModelProtocol.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 13/9/24.
//


import SwiftUI

protocol MainViewModelProtocol: ObservableObject {
    var isLoading: Bool { get set }
    var workflows: [Workflow] { get set }
    var isAlertPresented: Bool { get set }
    var isOnboardingPresented: Bool { get set }
    var apiResult: Result<WebhookResponse, ApiError>? { get set }

    func fetchData() async
    func toggleWorkflowActive(id: String, isActive: Bool) async
}
