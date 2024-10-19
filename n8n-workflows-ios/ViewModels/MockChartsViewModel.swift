//
//  MockChartsViewModel.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 19/10/24.
//

import Foundation

final class MockChartsViewModel: ChartsViewModelProtocol {
    var workflows: [Workflow]
    @Published var isLoading: Bool = false
    @Published var chartData: [ChartData] = []
    
    init(workflows: [Workflow]) {
        self.workflows = workflows
    }
    
    private func groupExecutionsByHour(executions: [Execution]) -> [SeriesData] {
        var groupedData: [String: Int] = [:]
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "yyyy-MM-dd'T'HH:00:00.000'Z'"

        let now = Date()
        let calendar = Calendar.current
        let oneDayAgo = calendar.date(byAdding: .hour, value: -24, to: now)!
        
        var allHours: [String] = []
        var currentHour = oneDayAgo
        while currentHour <= now {
            let hourString = hourFormatter.string(from: currentHour)
            allHours.append(hourString)
            currentHour = calendar.date(byAdding: .hour, value: 1, to: currentHour)!
        }
        
        for execution in executions {
            guard let startedAt = execution.startedAt.date else { continue }
            let hourKey = hourFormatter.string(from: startedAt)
            groupedData[hourKey, default: 0] += 1
        }
        
        let seriesData = allHours.map { hour -> SeriesData in
            let value = Double(groupedData[hour, default: 0])
            return SeriesData(category: hour, value: value, series: "Executions")
        }
        
        return seriesData
    }
    
    private func daysBetween(start: Date, end: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: start, to: end)
        return components.day ?? 0
    }

    private func groupExecutionsByDay(executions: [Execution], startDate: Date) -> [SeriesData] {
        var groupedData: [String: Int] = [:]
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyy-MM-dd'T'00:00:00.000'Z'"

        let currentDate = Date()
        let daysToGroup = daysBetween(start: startDate, end: currentDate)

        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .day, value: daysToGroup, to: startDate)!

        var allDays: [String] = []
        var currentDay = startDate
        while currentDay <= endDate {
            let dayString = dayFormatter.string(from: currentDay)
            allDays.append(dayString)
            currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay)!
        }

        for execution in executions {
            guard let startedAt = execution.startedAt.date else { continue }
            let dayKey = dayFormatter.string(from: startedAt)
            groupedData[dayKey, default: 0] += 1
        }

        let seriesData = allDays.map { day -> SeriesData in
            let value = Double(groupedData[day, default: 0])
            return SeriesData(category: day, value: value, series: "Executions")
        }

        return seriesData
    }
    
    func fetchData() async {
        let executions = Execution.dummyJsonData
        let last24hExecutions = executions.filter {
            guard let date = $0.startedAt.date,
                let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else { return false }
            return date > oneDayAgo
        }
        let last24ChartData = ChartData(title: "Last 24h", data: groupExecutionsByHour(executions: last24hExecutions), type: .line, categoryType: .hour)
        guard let lastDate = executions.last?.startedAt.date else { return }
        let last250ChartData = ChartData(title: "Last 250 executions", data: groupExecutionsByDay(executions: executions, startDate: lastDate), type: .line, categoryType: .day)
        let durationChartData = ChartData(
            title: "Duration",
            data: executions.enumerated().compactMap { index, execution in
                guard let duration = execution.executionTimeInSeconds else { return nil }
                return SeriesData(category: "\(index + 1)", value: duration, series: "Duration")
            },
            type: .line,
            categoryType: .value
        )
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        let last7dExecutions = executions.filter {
            guard let date = $0.startedAt.date, let sevenDaysAgo else { return false }
            return date > sevenDaysAgo
        }
        let last7dPointSeriesData: [SeriesData] = last7dExecutions.compactMap { execution in
            guard let date = execution.startedAt.date else { return nil }
            return SeriesData(category: execution.startedAt, value: date.timeToDouble, series: "Executions")
        }
        let last7dPointChartData = ChartData(title: "Weekly", data: last7dPointSeriesData, type: .point, categoryType: .day)
        await MainActor.run {
            chartData = [last7dPointChartData, last24ChartData, last250ChartData, durationChartData]
        }
    }
}
