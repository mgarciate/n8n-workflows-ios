//
//  ChartsView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 15/10/24.
//

import SwiftUI

struct ChartsView<ViewModel>: View where ViewModel: ChartsViewModelProtocol {
    @ObservedObject var viewModel: ViewModel
    @State private var isSelectWorkflowPresented: Bool = false
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                LazyVStack {
                    ForEach(viewModel.chartData) { chartData in
                        GroupBox(chartData.title) {
                            VStack {
                                switch chartData.type {
                                case .line:
                                    ChartLineMarksView(chartData: chartData)
                                case .point:
                                    ChartPointMarksView(chartData: chartData)
                                }
                            }
                            .frame(minHeight: !chartData.data.isEmpty ? 400 : 0)
                        }
                    }
                    Spacer()
                }
                .padding([.horizontal, .bottom])
            }
            if viewModel.isLoading {
                LoadingView(isLoading: viewModel.isLoading)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isSelectWorkflowPresented, onDismiss: {
            fetchDataTask()
        }) {
            SelectableWorkflowsView(workflows: viewModel.workflows, selectedIds: $viewModel.selectedWorkflowIds)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isSelectWorkflowPresented = true
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
                .disabled(viewModel.workflows.count <= 1)
            }
        }
        .onAppear() {
            fetchDataTask()
        }
    }
    
    private func fetchDataTask() {
        Task {
            await viewModel.fetchData()
        }
    }
}

struct ChartsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChartsView(viewModel: MockChartsViewModel(workflows: [Workflow.dummyWorkflows[0]]))
        }
    }
}
