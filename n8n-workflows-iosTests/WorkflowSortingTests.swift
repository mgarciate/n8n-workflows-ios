//
//  WorkflowSortingTests.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 20/12/24.
//


import XCTest
@testable import n8n_workflows_ios

class WorkflowSortingTests: XCTestCase {

    // Sample data for testing
    let workflows: [Workflow] = [
        Workflow(
            id: "1",
            name: "Zebra Workflow",
            active: true,
            createdAt: "2023-01-01T00:00:00Z",
            updatedAt: "2023-01-02T00:00:00Z",
            nodes: []
        ),
        Workflow(
            id: "2",
            name: "Apple Workflow",
            active: false,
            createdAt: "2023-01-03T00:00:00Z",
            updatedAt: "2023-01-04T00:00:00Z",
            nodes: []
        ),
        Workflow(
            id: "3",
            name: "Banana Workflow",
            active: true,
            createdAt: "2023-01-05T00:00:00Z",
            updatedAt: "2023-01-06T00:00:00Z",
            nodes: []
        ),
        Workflow(
            id: "4",
            name: "apple Workflow", // Lowercase version
            active: false,
            createdAt: "2023-01-07T00:00:00Z",
            updatedAt: "2023-01-08T00:00:00Z",
            nodes: []
        )
    ]

    func testSortWorkflowsByNameAscending() {
        let sortedWorkflows = workflows.sortedByLocalizedString(\.name)

        XCTAssertEqual(sortedWorkflows[0].name, "apple Workflow")
        XCTAssertEqual(sortedWorkflows[1].name, "Apple Workflow")
        XCTAssertEqual(sortedWorkflows[2].name, "Banana Workflow")
        XCTAssertEqual(sortedWorkflows[3].name, "Zebra Workflow")
    }

    func testSortWorkflowsNameDescending() {
        let sortedWorkflows = workflows.sortedByLocalizedString(\.name, ascending: false)

        XCTAssertEqual(sortedWorkflows[0].name, "Zebra Workflow")
        XCTAssertEqual(sortedWorkflows[1].name, "Banana Workflow")
        XCTAssertEqual(sortedWorkflows[2].name, "Apple Workflow")
        XCTAssertEqual(sortedWorkflows[3].name, "apple Workflow")
    }
}
