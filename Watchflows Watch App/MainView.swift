//
//  MainView.swift
//  Watchflows Watch App
//
//  Created by mgarciate on 8/10/24.
//

import SwiftUI

struct MainView<ViewModel>: View where ViewModel: MainViewModelProtocol {
    @StateObject var viewModel: ViewModel
    var body: some View {
        VStack {
            ContentUnavailableView("No workflows",
                                   systemImage: "flowchart",
                                   description: Text("Create workflows or configure you n8n instance in your iPhone"))
        }
        .padding()
        .onAppear() {
            Task {
                await viewModel.fetchData()
            }
        }
    }
}

#Preview {
    MainView(viewModel: MockMainViewModel())
}
