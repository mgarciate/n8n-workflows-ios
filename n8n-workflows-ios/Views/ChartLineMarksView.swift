//
//  ChartLineMarksView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 15/10/24.
//

import SwiftUI
import Charts

struct ChartLineMarksView: View {
    let chartData: ChartData
    @State private var xLocation: CGFloat?
    @State private var selectedEntry: SeriesData?
    @State private var xOffset: CGFloat = 0
    @State private var indicatorWidth: CGFloat = 0
    var body: some View {
        VStack {
            if chartData.data.isEmpty {
                Text("No data available")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                Chart(chartData.data) {
                    if let date = $0.category.date {
                        LineMark(
                            x: .value("Date", date),
                            y: .value("value", $0.value)
                        )
                        .foregroundStyle(by: .value("Series", $0.series))
                        .interpolationMethod(.catmullRom)
                    } else if let number = Int($0.category) {
                        LineMark(
                            x: .value("Date", number),
                            y: .value("value", $0.value)
                        )
                        .foregroundStyle(by: .value("Series", $0.series))
                        .interpolationMethod(.catmullRom)
                    } else {
                        LineMark(
                            x: .value("Date", $0.category),
                            y: .value("value", $0.value)
                        )
                        .foregroundStyle(by: .value("Series", $0.series))
                        .interpolationMethod(.catmullRom)
                    }
                }
                .chartXAxis {
                    AxisMarks(preset: .extended, values: .automatic) { value in
                        switch chartData.categoryType {
                        case .hour:
                            AxisValueLabel(format: .dateTime.hour())
                        case .day:
                            AxisValueLabel(format: .dateTime.day())
                        case .value:
                            AxisValueLabel()
                        }
                        AxisGridLine(centered: true)
                    }
                }
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .gesture(DragGesture()
                                .onChanged { value in
                                    guard let entry = findClosestData(to: value.location, proxy: proxy, geometry: geometry) else { return }
                                    select(entry: entry)
                                }
                                .onEnded { _ in
                                    clear()
                                }
                            )
                            .onTapGesture { location in
                                guard let entry = findClosestData(to: location, proxy: proxy, geometry: geometry) else { return }
                                select(entry: entry)
                            }
                        
                        if let xLocation, let selectedEntry {
                            let lineX = xLocation + geometry[proxy.plotAreaFrame].origin.x
                            let xOffset = max(0, min(geometry[proxy.plotAreaFrame].width - indicatorWidth, lineX - indicatorWidth / 2))
                            Path { path in
                                path.move(to: CGPoint(x: xLocation, y: 0.0))
                                path.addLine(to: CGPoint(x: xLocation, y: geometry[proxy.plotAreaFrame].height))
                            }
                            .stroke(Color.red, lineWidth: 2)
                            VStack {
                                VStack {
                                    GeometryReader { _ in
                                        VStack(alignment: .center, spacing: 0) {
                                            Text(selectedEntry.category.date?.dateString ?? "")
                                            VStack {
                                                ForEach(getValuesForCategory(category: selectedEntry.category)) { entry in
                                                    if let foregroundStyle = proxy.foregroundStyle(for: entry.series) {
                                                        let customFormatter: NumberFormatter = {
                                                            let formatter = NumberFormatter()
                                                            formatter.minimumFractionDigits = 0
                                                            formatter.maximumFractionDigits = 4
                                                            formatter.numberStyle = .decimal
                                                            return formatter
                                                        }()
                                                        Text("\(customFormatter.string(from: NSNumber(value: entry.value)) ?? "")")
                                                            .foregroundStyle(foregroundStyle)
                                                    }
                                                }
                                            }
                                        }
                                        .padding(5)
                                        .background(GeometryReader { childGeometry in
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color("Black"), lineWidth: 2)
                                                .background(Color("White"))
                                                .onAppear() {
                                                    indicatorWidth = childGeometry.size.width
                                                }
                                                .onChange(of: selectedEntry) { _ in
                                                    indicatorWidth = childGeometry.size.width
                                                }
                                        })
                                        .cornerRadius(10)
                                        .font(.caption)
                                        .offset(x: xOffset)
                                    }
                                }
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }
    
    private func findClosestData(to location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> SeriesData? {
        let plotSizeWidth: CGFloat
        if #available(iOS 17.0, *) {
            plotSizeWidth = proxy.plotSize.width
        } else {
            plotSizeWidth = geometry[proxy.plotAreaFrame].width
        }
        guard !chartData.data.isEmpty,
              location.x >= 0,
              location.x < plotSizeWidth,
              let firstDate = chartData.data.first?.category.date,
              let lastDate = chartData.data.last?.category.date else { return nil }
        let firstTimestamp = Int(firstDate.timeIntervalSince1970)
        let lastTimestamp = Int(lastDate.timeIntervalSince1970)
        let xScaleFactor = CGFloat(lastTimestamp - firstTimestamp) / plotSizeWidth
        let touchedTimestamp = firstTimestamp + Int(location.x * xScaleFactor)
        guard let entry = chartData.data.min(by: { abs(Int($0.category.date?.timeIntervalSince1970 ?? 0) - touchedTimestamp) < abs(Int($1.category.date?.timeIntervalSince1970 ?? 0) - touchedTimestamp) }) else { return nil }
        xLocation = plotSizeWidth * CGFloat(Int(entry.category.date?.timeIntervalSince1970 ?? 0) - firstTimestamp) / CGFloat(lastTimestamp - firstTimestamp)
        return entry
    }
    
    private func select(entry: SeriesData) {
        selectedEntry = entry
    }
    
    private func clear() {
        xLocation = nil
        selectedEntry = nil
    }
    
    private func getValuesForCategory(category: String) -> [SeriesData] {
        return chartData.data.filter { $0.category == category }
    }
}

struct ChartLineMarksView_Previews: PreviewProvider {
    static var previews: some View {
        ChartLineMarksView(chartData: ChartData.dummyData)
    }
}

extension SeriesData {
    static var dummyData: [SeriesData] {
        return [
            SeriesData(category: "2022-05-29T02:00:00.000Z", value: 0.217, series: "duration"),
            SeriesData(category: "2022-05-29T03:00:00.000Z", value: 0.358, series: "duration"),
            SeriesData(category: "2022-05-29T04:00:00.000Z", value: 0.292, series: "duration"),
            SeriesData(category: "2022-05-29T05:00:00.000Z", value: 0.195, series: "duration"),
            SeriesData(category: "2022-05-29T06:00:00.000Z", value: 0.312, series: "duration"),
            SeriesData(category: "2022-05-29T07:00:00.000Z", value: 0.453, series: "duration"),
            SeriesData(category: "2022-05-29T08:00:00.000Z", value: 0.186, series: "duration"),
            SeriesData(category: "2022-05-29T09:00:00.000Z", value: 0.371, series: "duration"),
            SeriesData(category: "2022-05-29T10:00:00.000Z", value: 0.225, series: "duration"),
            SeriesData(category: "2022-05-29T11:00:00.000Z", value: 0.489, series: "duration"),
            SeriesData(category: "2022-05-29T12:00:00.000Z", value: 0.174, series: "duration"),
            SeriesData(category: "2022-05-29T13:00:00.000Z", value: 0.423, series: "duration"),
            SeriesData(category: "2022-05-29T14:00:00.000Z", value: 0.392, series: "duration"),
            SeriesData(category: "2022-05-29T15:00:00.000Z", value: 0.362, series: "duration"),
            SeriesData(category: "2022-05-29T16:00:00.000Z", value: 0.144, series: "duration"),
            SeriesData(category: "2022-05-29T17:00:00.000Z", value: 0.411, series: "duration"),
            SeriesData(category: "2022-05-29T18:00:00.000Z", value: 0.197, series: "duration"),
            SeriesData(category: "2022-05-29T19:00:00.000Z", value: 0.226, series: "duration"),
            SeriesData(category: "2022-05-29T20:00:00.000Z", value: 0.487, series: "duration"),
            SeriesData(category: "2022-05-29T21:00:00.000Z", value: 0.241, series: "duration"),
            SeriesData(category: "2022-05-29T22:00:00.000Z", value: 0.374, series: "duration"),
            SeriesData(category: "2022-05-29T23:00:00.000Z", value: 0.165, series: "duration"),
            SeriesData(category: "2022-05-30T00:00:00.000Z", value: 0.428, series: "duration"),
            SeriesData(category: "2022-05-30T01:00:00.000Z", value: 0.498, series: "duration"),
            SeriesData(category: "2022-05-30T02:00:00.000Z", value: 0.212, series: "duration"),
            SeriesData(category: "2022-05-30T03:00:00.000Z", value: 0.157, series: "duration"),
            SeriesData(category: "2022-05-30T04:00:00.000Z", value: 0.335, series: "duration"),
            SeriesData(category: "2022-05-30T05:00:00.000Z", value: 0.421, series: "duration"),
            SeriesData(category: "2022-05-30T06:00:00.000Z", value: 0.312, series: "duration"),
            SeriesData(category: "2022-05-30T07:00:00.000Z", value: 0.198, series: "duration"),
            SeriesData(category: "2022-05-30T08:00:00.000Z", value: 0.413, series: "duration"),
            SeriesData(category: "2022-05-30T09:00:00.000Z", value: 0.325, series: "duration"),
            SeriesData(category: "2022-05-30T10:00:00.000Z", value: 0.231, series: "duration"),
            SeriesData(category: "2022-05-30T11:00:00.000Z", value: 0.452, series: "duration"),
            SeriesData(category: "2022-05-30T12:00:00.000Z", value: 0.344, series: "duration"),
            SeriesData(category: "2022-05-30T13:00:00.000Z", value: 0.482, series: "duration"),
            SeriesData(category: "2022-05-30T14:00:00.000Z", value: 0.269, series: "duration"),
            SeriesData(category: "2022-05-30T15:00:00.000Z", value: 0.216, series: "duration"),
            SeriesData(category: "2022-05-30T16:00:00.000Z", value: 0.394, series: "duration"),
            SeriesData(category: "2022-05-30T17:00:00.000Z", value: 0.488, series: "duration"),
            SeriesData(category: "2022-05-30T18:00:00.000Z", value: 0.221, series: "duration"),
            SeriesData(category: "2022-05-30T19:00:00.000Z", value: 0.346, series: "duration"),
            SeriesData(category: "2022-05-30T20:00:00.000Z", value: 0.183, series: "duration"),
            SeriesData(category: "2022-05-30T21:00:00.000Z", value: 0.275, series: "duration"),
            SeriesData(category: "2022-05-30T22:00:00.000Z", value: 0.392, series: "duration"),
            SeriesData(category: "2022-05-30T23:00:00.000Z", value: 0.117, series: "duration"),
            SeriesData(category: "2022-05-31T00:00:00.000Z", value: 0.453, series: "duration"),
            SeriesData(category: "2022-05-31T01:00:00.000Z", value: 0.236, series: "duration"),
            SeriesData(category: "2022-05-31T02:00:00.000Z", value: 0.261, series: "duration"),
            SeriesData(category: "2022-05-31T03:00:00.000Z", value: 0.177, series: "duration"),
            SeriesData(category: "2022-05-31T04:00:00.000Z", value: 0.491, series: "duration"),
            SeriesData(category: "2022-05-31T05:00:00.000Z", value: 0.356, series: "duration"),
            SeriesData(category: "2022-05-31T06:00:00.000Z", value: 0.218, series: "duration"),
            SeriesData(category: "2022-05-31T07:00:00.000Z", value: 0.364, series: "duration"),
            SeriesData(category: "2022-05-31T08:00:00.000Z", value: 0.448, series: "duration"),
            SeriesData(category: "2022-05-31T09:00:00.000Z", value: 0.128, series: "duration"),
            SeriesData(category: "2022-05-31T10:00:00.000Z", value: 0.254, series: "duration"),
            SeriesData(category: "2022-05-31T11:00:00.000Z", value: 0.382, series: "duration"),
            SeriesData(category: "2022-05-31T12:00:00.000Z", value: 0.176, series: "duration"),
            SeriesData(category: "2022-05-31T13:00:00.000Z", value: 0.241, series: "duration"),
            SeriesData(category: "2022-05-31T14:00:00.000Z", value: 0.198, series: "duration"),
            SeriesData(category: "2022-05-31T15:00:00.000Z", value: 0.457, series: "duration"),
            SeriesData(category: "2022-05-31T16:00:00.000Z", value: 0.263, series: "duration"),
            SeriesData(category: "2022-05-31T17:00:00.000Z", value: 0.423, series: "duration"),
            SeriesData(category: "2022-05-31T18:00:00.000Z", value: 0.399, series: "duration"),
            SeriesData(category: "2022-05-31T19:00:00.000Z", value: 0.194, series: "duration"),
            SeriesData(category: "2022-05-31T20:00:00.000Z", value: 0.473, series: "duration"),
            SeriesData(category: "2022-05-31T21:00:00.000Z", value: 0.386, series: "duration"),
            SeriesData(category: "2022-05-31T22:00:00.000Z", value: 0.415, series: "duration"),
            SeriesData(category: "2022-05-31T23:00:00.000Z", value: 0.263, series: "duration"),
            SeriesData(category: "2022-06-01T00:00:00.000Z", value: 0.314, series: "duration"),
            SeriesData(category: "2022-06-01T01:00:00.000Z", value: 0.225, series: "duration"),
            SeriesData(category: "2022-06-01T02:00:00.000Z", value: 0.337, series: "duration"),
            SeriesData(category: "2022-06-01T03:00:00.000Z", value: 0.145, series: "duration"),
            SeriesData(category: "2022-06-01T04:00:00.000Z", value: 0.492, series: "duration"),
            SeriesData(category: "2022-06-01T05:00:00.000Z", value: 0.281, series: "duration"),
            SeriesData(category: "2022-06-01T06:00:00.000Z", value: 0.367, series: "duration"),
            SeriesData(category: "2022-06-01T07:00:00.000Z", value: 0.399, series: "duration"),
            SeriesData(category: "2022-06-01T08:00:00.000Z", value: 0.222, series: "duration"),
            SeriesData(category: "2022-06-01T09:00:00.000Z", value: 0.298, series: "duration"),
            SeriesData(category: "2022-06-01T10:00:00.000Z", value: 0.481, series: "duration"),
            SeriesData(category: "2022-06-01T11:00:00.000Z", value: 0.413, series: "duration"),
            SeriesData(category: "2022-06-01T12:00:00.000Z", value: 0.247, series: "duration"),
            SeriesData(category: "2022-06-01T13:00:00.000Z", value: 0.197, series: "duration"),
            SeriesData(category: "2022-06-01T14:00:00.000Z", value: 0.341, series: "duration"),
            SeriesData(category: "2022-06-01T15:00:00.000Z", value: 0.389, series: "duration"),
            SeriesData(category: "2022-06-01T16:00:00.000Z", value: 0.219, series: "duration"),
            SeriesData(category: "2022-06-01T17:00:00.000Z", value: 0.455, series: "duration"),
            SeriesData(category: "2022-06-01T18:00:00.000Z", value: 0.183, series: "duration"),
            SeriesData(category: "2022-06-01T19:00:00.000Z", value: 0.431, series: "duration"),
            SeriesData(category: "2022-06-01T20:00:00.000Z", value: 0.275, series: "duration"),
            SeriesData(category: "2022-06-01T21:00:00.000Z", value: 0.354, series: "duration"),
            SeriesData(category: "2022-06-01T22:00:00.000Z", value: 0.326, series: "duration"),
            SeriesData(category: "2022-06-01T23:00:00.000Z", value: 0.482, series: "duration"),
            SeriesData(category: "2022-06-02T00:00:00.000Z", value: 0.277, series: "duration"),
            SeriesData(category: "2022-06-02T01:00:00.000Z", value: 0.223, series: "duration"),
            SeriesData(category: "2022-06-02T02:00:00.000Z", value: 0.144, series: "duration"),
            SeriesData(category: "2022-06-02T03:00:00.000Z", value: 0.317, series: "duration"),
            SeriesData(category: "2022-06-02T04:00:00.000Z", value: 0.491, series: "duration"),
            SeriesData(category: "2022-06-02T05:00:00.000Z", value: 0.385, series: "duration"),
            SeriesData(category: "2022-06-02T06:00:00.000Z", value: 0.465, series: "duration"),
            SeriesData(category: "2022-06-02T07:00:00.000Z", value: 0.356, series: "duration"),
            SeriesData(category: "2022-06-02T08:00:00.000Z", value: 0.298, series: "duration"),
            SeriesData(category: "2022-06-02T09:00:00.000Z", value: 0.417, series: "duration"),
            SeriesData(category: "2022-06-02T10:00:00.000Z", value: 0.439, series: "duration"),
            SeriesData(category: "2022-06-02T11:00:00.000Z", value: 0.389, series: "duration"),
            SeriesData(category: "2022-06-02T12:00:00.000Z", value: 0.374, series: "duration"),
            SeriesData(category: "2022-06-02T13:00:00.000Z", value: 0.219, series: "duration"),
            SeriesData(category: "2022-06-02T14:00:00.000Z", value: 0.313, series: "duration"),
            SeriesData(category: "2022-06-02T15:00:00.000Z", value: 0.197, series: "duration"),
            SeriesData(category: "2022-06-02T16:00:00.000Z", value: 0.364, series: "duration"),
            SeriesData(category: "2022-06-02T17:00:00.000Z", value: 0.418, series: "duration"),
            SeriesData(category: "2022-06-02T18:00:00.000Z", value: 0.175, series: "duration"),
            SeriesData(category: "2022-06-02T19:00:00.000Z", value: 0.249, series: "duration"),
            SeriesData(category: "2022-06-02T20:00:00.000Z", value: 0.474, series: "duration"),
            SeriesData(category: "2022-06-02T21:00:00.000Z", value: 0.284, series: "duration"),
            SeriesData(category: "2022-06-02T21:00:00.000Z", value: 0.374, series: "duration 2"),
            SeriesData(category: "2022-06-02T22:00:00.000Z", value: 0.472, series: "duration"),
            SeriesData(category: "2022-06-02T22:00:00.000Z", value: 0.197, series: "duration 2"),
            SeriesData(category: "2022-06-02T23:00:00.000Z", value: 0.392, series: "duration"),
            SeriesData(category: "2022-06-02T23:00:00.000Z", value: 0.284, series: "duration 2")
        ]
    }
}
