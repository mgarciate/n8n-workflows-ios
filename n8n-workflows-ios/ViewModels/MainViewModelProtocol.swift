//
//  MainViewModelProtocol.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 13/9/24.
//


import SwiftUI

protocol MainViewModelProtocol: ObservableObject {
    var workflows: [Workflow] { get set }

    func fetchData() async
    func toggleWorkflowActive(id: String, isActive: Bool)
}
