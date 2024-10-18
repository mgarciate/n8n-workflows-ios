//
//  ChartPointMarksView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 18/10/24.
//


import SwiftUI
import Charts

struct ChartPointMarksView: View {
    let chartData: ChartData
    
    var body: some View {
        VStack {
            if chartData.data.isEmpty {
                Text("No data available")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                Chart(chartData.data) {
                    PointMark(
                        x: .value("Date", $0.category.date ?? Date()),
                        y: .value("value", $0.value)
                    )
                    .foregroundStyle(by: .value("Series", $0.series))
                }
                .chartXScale(domain: Calendar.current.date(byAdding: .day, value: -7, to: Date())!...Date())
                .chartYScale(domain: 0...24)
                .chartXAxis {
                    AxisMarks(preset: .extended, values: .automatic) { value in
                        AxisValueLabel(format: .dateTime.weekday())
                        AxisGridLine(centered: true)
                    }
                }
                .chartYAxis {
                    AxisMarks(preset: .extended, values: .stride(by: 2)) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
            }
        }
    }
}

struct ChartPointMarksView_Previews: PreviewProvider {
    static var previews: some View {
        ChartPointMarksView(chartData: ChartData.dummyData)
    }
}
