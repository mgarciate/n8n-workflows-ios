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
