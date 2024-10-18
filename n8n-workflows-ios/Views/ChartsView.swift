//
//  ChartsView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 15/10/24.
//

import SwiftUI

enum ChartCategoryType {
    case hour, day, value
}

struct ChartData: Identifiable {
    let id = UUID()
    let title: String
    let data: [SeriesData]
    let type: ChartCategoryType
}

extension ChartData {
    static var dummyData: ChartData {
        ChartData(
            title: "Chart 1",
            data: SeriesData.dummyData,
            type: .hour
        )
    }
}

struct SeriesData: Identifiable, Equatable {
    var id = UUID()
    var category: String
    var value: Double
    var series: String
}

struct GraphEntry: Identifiable, Equatable {
    let id: UUID = UUID()
    let timestamp: Int
    let value: Double
}

extension GraphEntry {
    static var dummyData: GraphEntry {
        return GraphEntry(timestamp: 0, value: 0.0)
    }
    
    var dateString: String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" //Specify your format that you want
        return dateFormatter.string(from: date)
    }
    
    var dayDifference: Int? {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: date)
        let date2 = calendar.startOfDay(for: Date())
        return calendar.dateComponents([.day], from: date1, to: date2).day
    }
    
    var hour: Int? {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        return Calendar.current.dateComponents([.hour], from: date).hour
    }
    
    var weekdayAbbreviated: String? {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "en-US")
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: date)
    }
}

protocol ChartsViewModelProtocol: ObservableObject {
    var workflows: [Workflow] { get set }
    var isLoading: Bool { get set }
    var chartData: [ChartData] { get set }
    
    func fetchData() async
}

final class ChartsViewModel: ChartsViewModelProtocol {
    var workflows: [Workflow]
    @Published var isLoading: Bool = false
    @Published var chartData: [ChartData] = []
    
    init(workflows: [Workflow]) {
        self.workflows = workflows
    }
    
    private func groupExecutionsByHour(executions: [Execution]) -> [SeriesData] {
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
        let calendar = Calendar.current
        let currentDate = Date()
        let daysToGroup = daysBetween(start: startDate, end: currentDate) + 1
        guard let endDate = Calendar.current.date(byAdding: .day, value: daysToGroup, to: startDate) else { return [] }

        var groupedData: [String: Int] = [:]
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyy-MM-dd'T'00:00:00.000'Z'"

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
            return SeriesData(category: day, value: value, series: "Executions")
        }

        return seriesData
    }
    
    func fetchData() async {
        var executions: [Execution] = []
        
        await isLoading(true)
        do {
            let response: DataResponse<Execution> = try await WorkflowApiRequest().get(endpoint: .executions, params: ["workflowId": workflows[0].id])
            executions = response.data.reversed()
        } catch {
#if DEBUG
            print("Error", error)
#endif
        }
        await isLoading(false)
        
        let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        let last24hExecutions = executions.filter {
            guard let date = $0.startedAt.date,
                let oneDayAgo else { return false }
            return date > oneDayAgo
        }
        let last24hSeriesData: [SeriesData]
        if !last24hExecutions.isEmpty {
            last24hSeriesData = groupExecutionsByHour(executions: last24hExecutions)
        } else {
            last24hSeriesData = []
        }
        let last24hChartData = ChartData(title: "Last 24h", data: last24hSeriesData, type: .hour)
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        let last7dExecutions = executions.filter {
            guard let date = $0.startedAt.date, let sevenDaysAgo else { return false }
            return date > sevenDaysAgo
        }
        let last7dSeriesData: [SeriesData]
        if let firstDate = last7dExecutions.first?.startedAt.date {
            last7dSeriesData = groupExecutionsByDay(executions: last7dExecutions, startDate: firstDate)
        } else {
            last7dSeriesData = []
        }
        let last7dChartData = ChartData(title: "Last 7 days (max. 250 executions)", data: last7dSeriesData, type: .day)
        let durationChartData = ChartData(
            title: "Duration in seconds",
            data: executions.enumerated().compactMap { index, execution in
                guard let duration = execution.executionTimeInSeconds else { return nil }
                return SeriesData(category: "\(index + 1)", value: duration, series: "Duration")
            },
            type: .value
        )
        let lastErrorExecutions = executions.filter {
            !$0.finished
        }
        let lastErrorSeriesData: [SeriesData]
        if let firstDate = lastErrorExecutions.first?.startedAt.date {
            lastErrorSeriesData = groupExecutionsByDay(executions: lastErrorExecutions, startDate: firstDate)
        } else {
            lastErrorSeriesData = []
        }
        let lastErrorChartData = ChartData(title: "Last errors (max. 250 executions)", data: lastErrorSeriesData, type: .day)
        await MainActor.run {
            chartData = [last24hChartData, last7dChartData, durationChartData, lastErrorChartData]
        }
    }
    
    private func isLoading(_ isLoading: Bool) async {
        await MainActor.run {
            self.isLoading = isLoading
        }
    }
}

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
        let last24ChartData = ChartData(title: "Last 24h", data: groupExecutionsByHour(executions: last24hExecutions), type: .hour)
        guard let lastDate = executions.last?.startedAt.date else { return }
        let last250ChartData = ChartData(title: "Last 250 executions", data: groupExecutionsByDay(executions: executions, startDate: lastDate), type: .day)
        let durationChartData = ChartData(
            title: "Duration",
            data: executions.enumerated().compactMap { index, execution in
                guard let duration = execution.executionTimeInSeconds else { return nil }
                return SeriesData(category: "\(index + 1)", value: duration, series: "Duration")
            },
            type: .value
        )
        await MainActor.run {
            chartData = [last24ChartData, last250ChartData, durationChartData]
        }
    }
}

struct ChartsView<ViewModel>: View where ViewModel: ChartsViewModelProtocol {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                LazyVStack {
                    ForEach(viewModel.chartData) { chartData in
                        GroupBox(chartData.title) {
                            ChartLineMarksView(chartData: chartData)
                                .frame(minHeight: !chartData.data.isEmpty ? 200 : 0)
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
        .onAppear() {
            Task {
                await viewModel.fetchData()
            }
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
