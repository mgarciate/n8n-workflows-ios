//
//  ChartsViewModel.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 19/10/24.
//

import Foundation

final class ChartsViewModel: ChartsViewModelProtocol {
    private let defaultSelectedWorkflowsCount = 4
    var workflows: [Workflow]
    private var selectedWorkflows: [Workflow]
    @Published var selectedWorkflowIds: [String] {
        didSet {
            selectedWorkflows = workflows.filter { selectedWorkflowIds.contains($0.id) }
        }
    }
    @Published var isLoading: Bool = false
    @Published var chartData: [ChartData] = []
    
    init(workflows: [Workflow]) {
        self.workflows = workflows
        selectedWorkflows = workflows.filter { $0.active }
        if selectedWorkflows.count < defaultSelectedWorkflowsCount {
            let inactiveWorkflows = workflows.filter { !$0.active }
            let missingCount = defaultSelectedWorkflowsCount - selectedWorkflows.count
            selectedWorkflows.append(contentsOf: inactiveWorkflows.prefix(missingCount))
        }
        selectedWorkflows = Array(selectedWorkflows.prefix(4))
        selectedWorkflowIds = selectedWorkflows.map { $0.id }
    }
    
    private func groupExecutionsByHour(executions: [Execution], series: String) -> [SeriesData] {
        let now = Date()
        let calendar = Calendar.current
        guard let oneDayAgo = calendar.date(byAdding: .hour, value: -24, to: now) else { return [] }
        
        var groupedData: [String: Int] = [:]
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "yyyy-MM-dd'T'HH:00:00.000'Z'"
        
        var allHours: [String] = []
        var currentHour = oneDayAgo
        while currentHour <= now {
            let hourString = hourFormatter.string(from: currentHour)
            allHours.append(hourString)
            guard let nextHour = calendar.date(byAdding: .hour, value: 1, to: currentHour) else { break }
            currentHour = nextHour
        }
        
        for execution in executions {
            guard let startedAt = execution.startedAt.date else { continue }
            let hourKey = hourFormatter.string(from: startedAt)
            groupedData[hourKey, default: 0] += 1
        }
        
        let seriesData = allHours.map { hour -> SeriesData in
            let value = Double(groupedData[hour, default: 0])
            return SeriesData(category: hour, value: value, series: series)
        }
        
        return seriesData
    }
    
    private func daysBetween(start: Date, end: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: start, to: end)
        return components.day ?? 0
    }

    private func groupExecutionsByDay(executions: [Execution], startDate: Date, dateFormat: String, series: String) -> [SeriesData] {
        let calendar = Calendar.current
        let currentDate = Date()
        let daysToGroup = daysBetween(start: startDate, end: currentDate) + 1
        guard let endDate = Calendar.current.date(byAdding: .day, value: daysToGroup, to: startDate) else { return [] }

        var groupedData: [String: Int] = [:]
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = dateFormat

        var allDays: [String] = []
        var currentDay = startDate
        while currentDay <= endDate {
            let dayString = dayFormatter.string(from: currentDay)
            allDays.append(dayString)
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDay) else { break }
            currentDay = nextDay
        }

        for execution in executions {
            guard let startedAt = execution.startedAt.date else { continue }
            let dayKey = dayFormatter.string(from: startedAt)
            groupedData[dayKey, default: 0] += 1
        }

        let seriesData = allDays.map { day -> SeriesData in
            let value = Double(groupedData[day, default: 0])
            return SeriesData(category: day, value: value, series: series)
        }

        return seriesData
    }
    
    func fetchData() async {
        var results: [[Execution]] = []
        await isLoading(true)
        await withTaskGroup(of: [Execution]?.self) { group in
            for workflow in selectedWorkflows {
                group.addTask {
                    var allData: [Execution] = []
                    var nextCursor: String? = nil
                    
                    repeat {
                        do {
                            let params: [String: String] = nextCursor != nil ? ["workflowId": workflow.id, "cursor": nextCursor!] : ["workflowId": workflow.id]
                            let response: DataResponse<Execution> = try await WorkflowApiRequest().get(endpoint: .executions, params: params)
                            allData.append(contentsOf: response.data)
                            nextCursor = response.nextCursor
                        } catch {
#if DEBUG
                            print("Failed to fetch data from \(workflow.id): \(error)")
#endif
                            nextCursor = nil
                        }
                        guard let lastDate = allData.last?.startedAt.date,
                                self.daysBetween(start: lastDate, end: Date()) <= 7 else { break }
                        guard allData.count < 2000 else { break }
                        
                    } while nextCursor != nil
                    
                    return allData.isEmpty ? nil : allData.reversed()
                }
            }
            
            for await result in group {
                if let data = result {
                    results.append(data)
                }
            }
        }
        await isLoading(false)
        
        var last24hSeriesData: [SeriesData] = []
        var last7dSeriesData: [SeriesData] = []
        var lastErrorSeriesData: [SeriesData] = []
        var durationSeriesData: [SeriesData] = []
        var last7dPointSeriesData: [SeriesData] = []
        
        let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        for (index, executions) in results.enumerated() {
#if DEBUG
            print("Element at index \(index) is \(selectedWorkflows[index].name)")
#endif
            let maxLength = 10
            let series: String = index < selectedWorkflows.count ?
            (selectedWorkflows[index].name.count > maxLength ? String("\(index + 1) \(selectedWorkflows[index].name.prefix(maxLength))...") : selectedWorkflows[index].name) :
            String("\(index + 1) No name")
            
            let last24hExecutions = executions.filter {
                guard let date = $0.startedAt.date,
                    let oneDayAgo else { return false }
                return date > oneDayAgo
            }
            last24hSeriesData.append(contentsOf: groupExecutionsByHour(executions: last24hExecutions, series: series))
            
            let last7dExecutions = executions.filter {
                guard let date = $0.startedAt.date else { return false }
                return date > sevenDaysAgo
            }
            if !last7dExecutions.isEmpty {
                last7dSeriesData.append(contentsOf: groupExecutionsByDay(executions: last7dExecutions, startDate: sevenDaysAgo, dateFormat: "yyyy-MM-dd'T'00:00:00.000'Z'", series: series))
            }
            durationSeriesData.append(contentsOf:
                                        executions.enumerated().compactMap { index, execution in
                guard let duration = execution.executionTimeInSeconds else { return nil }
                return SeriesData(category: "\(index + 1)", value: duration, series: series)
            }
            )
            let lastErrorExecutions = executions.filter {
                !$0.finished
            }
            if let firstDate = lastErrorExecutions.first?.startedAt.date {
                lastErrorSeriesData.append(contentsOf: groupExecutionsByDay(executions: lastErrorExecutions, startDate: firstDate, dateFormat: "yyyy-MM-dd'T'00:00:00.000'Z'", series: series))
            }
            last7dPointSeriesData.append(contentsOf:
                                            last7dExecutions.compactMap { execution in
                guard let date = execution.startedAt.date else { return nil }
                return SeriesData(category: execution.startedAt, value: date.timeToDouble, series: series)
            }
            )
        }
        
        let last24hChartData = ChartData(title: "Last 24h", data: last24hSeriesData, type: .line, categoryType: .hour)
        let last7dChartData = ChartData(title: "Last 7 days (max. 250 executions)", data: last7dSeriesData, type: .line, categoryType: .day)
        let durationChartData = ChartData(
            title: "Duration in seconds",
            data: durationSeriesData,
            type: .line,
            categoryType: .value
        )
        let lastErrorChartData = ChartData(title: "Last errors (max. 250 executions)", data: lastErrorSeriesData, type: .line, categoryType: .day)
        let last7dPointChartData = ChartData(title: "Weekly", data: last7dPointSeriesData, type: .point, categoryType: .day)
        
        await MainActor.run {
            chartData = [
                last24hChartData,
                last7dChartData,
                durationChartData,
                lastErrorChartData,
                last7dPointChartData,
            ]
        }
    }
    
    private func isLoading(_ isLoading: Bool) async {
        await MainActor.run {
            self.isLoading = isLoading
        }
    }
}
