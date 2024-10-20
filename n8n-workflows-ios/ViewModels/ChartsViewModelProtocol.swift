//
//  ChartsViewModelProtocol.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 19/10/24.
//

import Foundation

protocol ChartsViewModelProtocol: ObservableObject {
    var workflows: [Workflow] { get set }
    var selectedWorkflowIds: [String] { get set }
    var isLoading: Bool { get set }
    var chartData: [ChartData] { get set }
    
    func fetchData() async
}
