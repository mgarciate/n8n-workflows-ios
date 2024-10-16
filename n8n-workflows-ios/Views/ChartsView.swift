//
//  ChartsView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 15/10/24.
//

import SwiftUI

struct ChartData: Identifiable, Equatable {
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
    var chartData: [ChartData] { get set }
    
    func fetchData()
}

final class ChartsViewModel: ChartsViewModelProtocol {
    @Published var chartData: [ChartData] = []
    
    func fetchData() {
        chartData = ChartData.dummyChartData
    }
}

final class MockChartsViewModel: ChartsViewModelProtocol {
    @Published var chartData: [ChartData] = []
    
    func fetchData() {
        chartData = ChartData.dummyChartData
    }
}

struct ChartsView<ViewModel>: View where ViewModel: ChartsViewModelProtocol {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            HStack {
                Image("AppIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                Text("appName")
                    .font(Font.title3.bold())
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            VStack {
                GroupBox("Last 24h") {
                    ChartLineMarksView(chartData: viewModel.chartData)
                }
                .frame(minHeight: 0, maxHeight: .infinity)
                GroupBox("Last executions (max. 250)") {
                    ChartLineMarksView(chartData: viewModel.chartData)
                }
                .frame(minHeight: 0, maxHeight: .infinity)
                Spacer()
            }
            .padding([.horizontal, .bottom])
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            viewModel.fetchData()
        }
    }
}

struct ChartsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChartsView(viewModel: MockChartsViewModel())
        }
    }
}
