//
//  WatchflowsApp.swift
//  Watchflows Watch App
//
//  Created by mgarciate on 8/10/24.
//

import SwiftUI

@Observable
class WorkflowRouter {
    enum Route: Hashable {
        case webhooks(workflow: Workflow)
        case executions(workflow: Workflow)
    }
    
    var navigationPath = NavigationPath()

    func navigateTo(route: Route) {
        navigationPath.append(route)
    }
}

@main
struct Watchflows_Watch_AppApp: App {
    @State private var router = WorkflowRouter()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.navigationPath) {
                MainView(viewModel: MainViewModel())
                    .environment(router)
                    .navigationDestination(for: WorkflowRouter.Route.self) { route in
                        switch route {
                        case .webhooks(let workflow):
                            WorkflowWebhooksView(workflow: workflow)
                                .environment(router)
                        case .executions(let workflow):
                            WorkflowExecutionsView(viewModel: WorkflowExecutionsViewModel(workflow: workflow))
                                .environment(router)
                        }
                    }
            }
        }
    }
}
