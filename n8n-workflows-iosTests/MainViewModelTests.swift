//
//  MainViewModelTests.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 5/1/25.
//


import XCTest
@testable import n8n_workflows_ios

final class MockUserDefault: UserDefaults {
    var persistenceValue: Any?
    var persistenceKey: String?
        
//    override func set(_ value: Any?, forKey defaultName: String) {
//        persistenceValue = value as? String
//        persistenceKey = defaultName
//    }
//    
//    override func string(forKey defaultName: String) -> String? {
//        persistenceValue as? String
//    }
}

final class MainViewModelTests: XCTestCase {
    let userDefaultsSuiteName = "FooTests"
    let workflows = [
        Workflow(id: "1", name: "Charlie", active: true, createdAt: "2023-01-05T00:00:00.000Z", updatedAt: "2023-01-02T00:00:00.000Z", nodes: []),
        Workflow(id: "3", name: "Alpha", active: true, createdAt: "2023-01-01T00:00:00.000Z", updatedAt: "2023-01-06T00:00:00.000Z", nodes: []),
        Workflow(id: "2", name: "Bravo", active: true, createdAt: "2023-01-03T00:00:00.000Z", updatedAt: "2023-01-04T00:00:00.000Z", nodes: []),
    ]
    var userDefaults: UserDefaults!
    
    override func setUpWithError() throws {
        userDefaults = UserDefaults(suiteName: userDefaultsSuiteName)
    }
    
    override func tearDownWithError() throws {
        userDefaults.removePersistentDomain(forName: userDefaultsSuiteName)
    }
    
    func testSortWorkflowsByDefault() {
        let viewModel = MainViewModel(userDefaults: userDefaults)

        let sortedWorkflows = viewModel.sortWorkflows(workflows)

        XCTAssertEqual(sortedWorkflows.map { $0.updatedAt }, ["2023-01-06T00:00:00.000Z", "2023-01-04T00:00:00.000Z", "2023-01-02T00:00:00.000Z"])
    }
    
    func testSortWorkflowsByNameAscending() {
        userDefaults.set(WorkflowSortOption.name.rawValue, forKey: "sort")
        userDefaults.set(SortOrder.ascending.rawValue, forKey: "order")
        let viewModel = MainViewModel(userDefaults: userDefaults)

        let sortedWorkflows = viewModel.sortWorkflows(workflows)

        XCTAssertEqual(sortedWorkflows.map { $0.name }, ["Alpha", "Bravo", "Charlie"])
    }

    func testSortWorkflowsByCreatedAtDescending() {
        let viewModel = MainViewModel(userDefaults: userDefaults)

        userDefaults.set(WorkflowSortOption.createdAt.rawValue, forKey: "sort")
        userDefaults.set(SortOrder.descending.rawValue, forKey: "order")

        let sortedWorkflows = viewModel.sortWorkflows(workflows)

        XCTAssertEqual(sortedWorkflows.map { $0.createdAt }, ["2023-01-05T00:00:00.000Z", "2023-01-03T00:00:00.000Z", "2023-01-01T00:00:00.000Z"])
    }

    func testSortWorkflowsByUpdatedAtAscending() {
        let viewModel = MainViewModel(userDefaults: userDefaults)

        userDefaults.set(WorkflowSortOption.updatedAt.rawValue, forKey: "sort")
        userDefaults.set(SortOrder.ascending.rawValue, forKey: "order")

        let sortedWorkflows = viewModel.sortWorkflows(workflows)

        XCTAssertEqual(sortedWorkflows.map { $0.updatedAt }, ["2023-01-02T00:00:00.000Z", "2023-01-04T00:00:00.000Z", "2023-01-06T00:00:00.000Z"])
    }
}
