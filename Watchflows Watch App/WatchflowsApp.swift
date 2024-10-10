//
//  WatchflowsApp.swift
//  Watchflows Watch App
//
//  Created by mgarciate on 8/10/24.
//

import SwiftUI
import SwiftData

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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([WebhookConfiguration.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer \(error)")
        }
    }()
    
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
        .modelContainer(sharedModelContainer)
    }
}
