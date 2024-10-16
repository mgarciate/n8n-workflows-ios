//
//  ChartLineMarksView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 15/10/24.
//

import SwiftUI
import Charts

struct ChartLineMarksView: View {
    let entries : [GraphEntry]
    @State private var xLocation: CGFloat?
    @State private var selectedEntry: GraphEntry?
    @State private var xOffset: CGFloat = 0
    @State private var indicatorWidth: CGFloat = 0
    var body: some View {
        Chart(entries) {
            LineMark(
                x: .value("Date", Date(timeIntervalSince1970: TimeInterval($0.timestamp))),
                y: .value("value", $0.value)
            )
            .foregroundStyle(by: .value("Value", "value"))
            .interpolationMethod(.catmullRom)
//            LineMark(
//                x: .value("Date", Date(timeIntervalSince1970: TimeInterval($0.timestamp))),
//                y: .value(Resources.Strings.Common.Speed.fast, $0.fast)
//            )
//            .foregroundStyle(by: .value("Value", Resources.Strings.Common.Speed.fast))
//            .interpolationMethod(.catmullRom)
//            LineMark(
//                x: .value("Date", Date(timeIntervalSince1970: TimeInterval($0.timestamp))),
//                y: .value(Resources.Strings.Common.Speed.standard, $0.average)
//            )
//            .foregroundStyle(by: .value("Value", Resources.Strings.Common.Speed.standard))
//            .interpolationMethod(.catmullRom)
        }
        .chartForegroundStyleScale ([
            "value": .pink,
//            Resources.Strings.Common.Speed.fast: .blue,
//            Resources.Strings.Common.Speed.standard: .green,
        ])
        .chartXAxis {
            AxisMarks(preset: .extended, values: .automatic) { value in
//                switch graphType {
//                case .daily:
//                    AxisValueLabel(format: .dateTime.hour())
//                case .weekly:
//                    AxisValueLabel(format: .dateTime.day())
//                }
                AxisValueLabel(format: .dateTime.hour())
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
            }
        }
        .chartBackground { proxy in
            GeometryReader { geometry in
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
                                    Text(selectedEntry.dateString)
                                    HStack(spacing: 10) {
                                        Text("\(selectedEntry.value)")
                                            .foregroundColor(.pink)
//                                        Rectangle()
//                                            .foregroundColor(.gray)
//                                            .frame(width: 1, height: 10)
//                                        Text(selectedEntry.fast.gasValueString)
//                                            .foregroundColor(.blue)
//                                        Rectangle()
//                                            .foregroundColor(.gray)
//                                            .frame(width: 1, height: 10)
//                                        Text(selectedEntry.average.gasValueString)
//                                            .foregroundColor(.green)
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
        .onAppear() {
            
        }
    }
    
    private func findClosestData(to location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> GraphEntry? {
        let plotSizeWidth: CGFloat
        if #available(iOS 17.0, *) {
            plotSizeWidth = proxy.plotSize.width
        } else {
            plotSizeWidth = geometry[proxy.plotAreaFrame].width
        }
        guard !entries.isEmpty,
              location.x >= 0,
              location.x < plotSizeWidth,
              let firstTimestamp = entries.last?.timestamp,
              let lastTimestamp = entries.first?.timestamp else { return nil }
        let xScaleFactor = CGFloat(lastTimestamp - firstTimestamp) / plotSizeWidth
        let touchedTimestamp = firstTimestamp + Int(location.x * xScaleFactor)
        guard let entry = entries.min(by: { abs($0.timestamp - touchedTimestamp) < abs($1.timestamp - touchedTimestamp) }) else { return nil }
        xLocation = plotSizeWidth * CGFloat(entry.timestamp - firstTimestamp) / CGFloat(lastTimestamp - firstTimestamp)
        return entry
    }
    
    private func select(entry: GraphEntry) {
        selectedEntry = entry
    }
    
    private func clear() {
        xLocation = nil
        selectedEntry = nil
    }
}

struct ChartLineMarksView_Previews: PreviewProvider {
    static var previews: some View {
        ChartLineMarksView(entries: GraphEntry.dummyDailyData)
    }
}

extension GraphEntry {

    static var dummyDailyData: [GraphEntry] {
        return [
            GraphEntry(timestamp: 1654323000, value: 0.222),
            GraphEntry(timestamp: 1654323600, value: 0.358),
            GraphEntry(timestamp: 1654324200, value: 0.142),
            GraphEntry(timestamp: 1654324800, value: 0.293),
            GraphEntry(timestamp: 1654325400, value: 0.402),
            GraphEntry(timestamp: 1654326000, value: 0.195),
            GraphEntry(timestamp: 1654326600, value: 0.329),
            GraphEntry(timestamp: 1654327200, value: 0.276),
            GraphEntry(timestamp: 1654327800, value: 0.141),
            GraphEntry(timestamp: 1654328400, value: 0.381),
            GraphEntry(timestamp: 1654329000, value: 0.192),
            GraphEntry(timestamp: 1654329600, value: 0.167),
            GraphEntry(timestamp: 1654330200, value: 0.214),
            GraphEntry(timestamp: 1654330800, value: 0.384),
            GraphEntry(timestamp: 1654331400, value: 0.297),
            GraphEntry(timestamp: 1654332000, value: 0.136),
            GraphEntry(timestamp: 1654332600, value: 0.453),
            GraphEntry(timestamp: 1654333200, value: 0.127),
            GraphEntry(timestamp: 1654333800, value: 0.235),
            GraphEntry(timestamp: 1654334400, value: 0.341),
            GraphEntry(timestamp: 1654335000, value: 0.212),
            GraphEntry(timestamp: 1654335600, value: 0.427),
            GraphEntry(timestamp: 1654336200, value: 0.167),
            GraphEntry(timestamp: 1654336800, value: 0.334),
            GraphEntry(timestamp: 1654337400, value: 0.401),
            GraphEntry(timestamp: 1654338000, value: 0.244),
            GraphEntry(timestamp: 1654338600, value: 0.456),
            GraphEntry(timestamp: 1654339200, value: 0.372),
            GraphEntry(timestamp: 1654339800, value: 0.295),
            GraphEntry(timestamp: 1654340400, value: 0.107),
            GraphEntry(timestamp: 1654341000, value: 0.221),
            GraphEntry(timestamp: 1654341600, value: 0.151),
            GraphEntry(timestamp: 1654342200, value: 0.298),
            GraphEntry(timestamp: 1654342800, value: 0.123),
            GraphEntry(timestamp: 1654343400, value: 0.483),
            GraphEntry(timestamp: 1654344000, value: 0.291),
            GraphEntry(timestamp: 1654344600, value: 0.128),
            GraphEntry(timestamp: 1654345200, value: 0.251),
            GraphEntry(timestamp: 1654345800, value: 0.352),
            GraphEntry(timestamp: 1654346400, value: 0.463),
            GraphEntry(timestamp: 1654347000, value: 0.419),
            GraphEntry(timestamp: 1654347600, value: 0.185),
            GraphEntry(timestamp: 1654348200, value: 0.367),
            GraphEntry(timestamp: 1654348800, value: 0.423),
            GraphEntry(timestamp: 1654349400, value: 0.306),
            GraphEntry(timestamp: 1654350000, value: 0.217),
            GraphEntry(timestamp: 1654350600, value: 0.196),
            GraphEntry(timestamp: 1654351200, value: 0.471),
            GraphEntry(timestamp: 1654351800, value: 0.249),
            GraphEntry(timestamp: 1654352400, value: 0.358),
            GraphEntry(timestamp: 1654353000, value: 0.392),
            GraphEntry(timestamp: 1654353600, value: 0.317),
            GraphEntry(timestamp: 1654354200, value: 0.131),
            GraphEntry(timestamp: 1654354800, value: 0.461),
            GraphEntry(timestamp: 1654355400, value: 0.439),
            GraphEntry(timestamp: 1654356000, value: 0.224),
            GraphEntry(timestamp: 1654356600, value: 0.251),
            GraphEntry(timestamp: 1654357200, value: 0.374),
            GraphEntry(timestamp: 1654357800, value: 0.495),
            GraphEntry(timestamp: 1654358400, value: 0.115),
            GraphEntry(timestamp: 1654359000, value: 0.346),
            GraphEntry(timestamp: 1654359600, value: 0.293),
            GraphEntry(timestamp: 1654360200, value: 0.227),
            GraphEntry(timestamp: 1654360800, value: 0.383),
            GraphEntry(timestamp: 1654361400, value: 0.419),
            GraphEntry(timestamp: 1654362000, value: 0.264),
            GraphEntry(timestamp: 1654362600, value: 0.351),
            GraphEntry(timestamp: 1654363200, value: 0.179),
            GraphEntry(timestamp: 1654363800, value: 0.487),
            GraphEntry(timestamp: 1654364400, value: 0.327),
            GraphEntry(timestamp: 1654365000, value: 0.173),
            GraphEntry(timestamp: 1654365600, value: 0.132),
            GraphEntry(timestamp: 1654366200, value: 0.477),
            GraphEntry(timestamp: 1654366800, value: 0.368),
            GraphEntry(timestamp: 1654367400, value: 0.426),
            GraphEntry(timestamp: 1654368000, value: 0.115),
            GraphEntry(timestamp: 1654368600, value: 0.182),
            GraphEntry(timestamp: 1654369200, value: 0.473),
            GraphEntry(timestamp: 1654369800, value: 0.299),
            GraphEntry(timestamp: 1654370400, value: 0.324),
            GraphEntry(timestamp: 1654371000, value: 0.462),
            GraphEntry(timestamp: 1654371600, value: 0.187),
            GraphEntry(timestamp: 1654372200, value: 0.281),
            GraphEntry(timestamp: 1654372800, value: 0.149),
            GraphEntry(timestamp: 1654373400, value: 0.495),
            GraphEntry(timestamp: 1654374000, value: 0.109),
            GraphEntry(timestamp: 1654374600, value: 0.397),
            GraphEntry(timestamp: 1654375200, value: 0.184),
            GraphEntry(timestamp: 1654375800, value: 0.288),
            GraphEntry(timestamp: 1654376400, value: 0.467),
            GraphEntry(timestamp: 1654377000, value: 0.129),
            GraphEntry(timestamp: 1654377600, value: 0.263),
            GraphEntry(timestamp: 1654378200, value: 0.195),
            GraphEntry(timestamp: 1654378800, value: 0.495),
            GraphEntry(timestamp: 1654379400, value: 0.349),
            GraphEntry(timestamp: 1654380000, value: 0.216),
            GraphEntry(timestamp: 1654380600, value: 0.273),
            GraphEntry(timestamp: 1654381200, value: 0.497),
            GraphEntry(timestamp: 1654381800, value: 0.302),
            GraphEntry(timestamp: 1654382400, value: 0.157),
            GraphEntry(timestamp: 1654383000, value: 0.186),
            GraphEntry(timestamp: 1654383600, value: 0.452),
            GraphEntry(timestamp: 1654384200, value: 0.236),
            GraphEntry(timestamp: 1654384800, value: 0.144),
            GraphEntry(timestamp: 1654385400, value: 0.393),
            GraphEntry(timestamp: 1654386000, value: 0.498),
            GraphEntry(timestamp: 1654386600, value: 0.358),
            GraphEntry(timestamp: 1654387200, value: 0.149),
            GraphEntry(timestamp: 1654387800, value: 0.489),
            GraphEntry(timestamp: 1654388400, value: 0.221),
            GraphEntry(timestamp: 1654389000, value: 0.194),
            GraphEntry(timestamp: 1654389600, value: 0.364),
            GraphEntry(timestamp: 1654390200, value: 0.282),
            GraphEntry(timestamp: 1654390800, value: 0.442),
            GraphEntry(timestamp: 1654391400, value: 0.498),
            GraphEntry(timestamp: 1654392000, value: 0.323),
            GraphEntry(timestamp: 1654392600, value: 0.263),
            GraphEntry(timestamp: 1654393200, value: 0.398),
            GraphEntry(timestamp: 1654393800, value: 0.197),
            GraphEntry(timestamp: 1654394400, value: 0.465),
            GraphEntry(timestamp: 1654395000, value: 0.344),
            GraphEntry(timestamp: 1654395600, value: 0.416),
            GraphEntry(timestamp: 1654396200, value: 0.328),
            GraphEntry(timestamp: 1654396800, value: 0.423),
            GraphEntry(timestamp: 1654397400, value: 0.477),
            GraphEntry(timestamp: 1654398000, value: 0.199),
            GraphEntry(timestamp: 1654398600, value: 0.357),
            GraphEntry(timestamp: 1654399200, value: 0.486),
            GraphEntry(timestamp: 1654399800, value: 0.293),
            GraphEntry(timestamp: 1654400400, value: 0.159),
            GraphEntry(timestamp: 1654401000, value: 0.214),
            GraphEntry(timestamp: 1654401600, value: 0.437),
            GraphEntry(timestamp: 1654402200, value: 0.312),
            GraphEntry(timestamp: 1654402800, value: 0.178),
            GraphEntry(timestamp: 1654403400, value: 0.288),
            GraphEntry(timestamp: 1654404000, value: 0.421),
            GraphEntry(timestamp: 1654404600, value: 0.361),
            GraphEntry(timestamp: 1654405200, value: 0.289),
            GraphEntry(timestamp: 1654405800, value: 0.463),
            GraphEntry(timestamp: 1654406400, value: 0.225),
            GraphEntry(timestamp: 1654407000, value: 0.181),
            GraphEntry(timestamp: 1654407600, value: 0.313),
            GraphEntry(timestamp: 1654408200, value: 0.437),
            GraphEntry(timestamp: 1654408800, value: 0.482),
            GraphEntry(timestamp: 1654409880, value: 0.234)
        ]
    }

    static var dummyWeeklyData: [GraphEntry] {
        return [
            GraphEntry(timestamp: 1653807600, value: 0.217),
            GraphEntry(timestamp: 1653811200, value: 0.358),
            GraphEntry(timestamp: 1653814800, value: 0.292),
            GraphEntry(timestamp: 1653818400, value: 0.195),
            GraphEntry(timestamp: 1653822000, value: 0.312),
            GraphEntry(timestamp: 1653825600, value: 0.453),
            GraphEntry(timestamp: 1653829200, value: 0.186),
            GraphEntry(timestamp: 1653832800, value: 0.371),
            GraphEntry(timestamp: 1653836400, value: 0.225),
            GraphEntry(timestamp: 1653840000, value: 0.489),
            GraphEntry(timestamp: 1653843600, value: 0.174),
            GraphEntry(timestamp: 1653847200, value: 0.423),
            GraphEntry(timestamp: 1653850800, value: 0.392),
            GraphEntry(timestamp: 1653854400, value: 0.362),
            GraphEntry(timestamp: 1653858000, value: 0.144),
            GraphEntry(timestamp: 1653861600, value: 0.411),
            GraphEntry(timestamp: 1653865200, value: 0.197),
            GraphEntry(timestamp: 1653868800, value: 0.226),
            GraphEntry(timestamp: 1653872400, value: 0.487),
            GraphEntry(timestamp: 1653876000, value: 0.241),
            GraphEntry(timestamp: 1653879600, value: 0.374),
            GraphEntry(timestamp: 1653883200, value: 0.165),
            GraphEntry(timestamp: 1653886800, value: 0.428),
            GraphEntry(timestamp: 1653890400, value: 0.498),
            GraphEntry(timestamp: 1653894000, value: 0.212),
            GraphEntry(timestamp: 1653897600, value: 0.157),
            GraphEntry(timestamp: 1653901200, value: 0.335),
            GraphEntry(timestamp: 1653904800, value: 0.421),
            GraphEntry(timestamp: 1653908400, value: 0.312),
            GraphEntry(timestamp: 1653912000, value: 0.198),
            GraphEntry(timestamp: 1653915600, value: 0.413),
            GraphEntry(timestamp: 1653919200, value: 0.325),
            GraphEntry(timestamp: 1653922800, value: 0.231),
            GraphEntry(timestamp: 1653926400, value: 0.452),
            GraphEntry(timestamp: 1653930000, value: 0.344),
            GraphEntry(timestamp: 1653933600, value: 0.482),
            GraphEntry(timestamp: 1653937200, value: 0.269),
            GraphEntry(timestamp: 1653940800, value: 0.216),
            GraphEntry(timestamp: 1653944400, value: 0.394),
            GraphEntry(timestamp: 1653948000, value: 0.488),
            GraphEntry(timestamp: 1653951600, value: 0.221),
            GraphEntry(timestamp: 1653955200, value: 0.346),
            GraphEntry(timestamp: 1653958800, value: 0.183),
            GraphEntry(timestamp: 1653962400, value: 0.275),
            GraphEntry(timestamp: 1653966000, value: 0.392),
            GraphEntry(timestamp: 1653969600, value: 0.117),
            GraphEntry(timestamp: 1653973200, value: 0.453),
            GraphEntry(timestamp: 1653976800, value: 0.236),
            GraphEntry(timestamp: 1653980400, value: 0.261),
            GraphEntry(timestamp: 1653984000, value: 0.177),
            GraphEntry(timestamp: 1653987600, value: 0.491),
            GraphEntry(timestamp: 1653991200, value: 0.356),
            GraphEntry(timestamp: 1653994800, value: 0.218),
            GraphEntry(timestamp: 1653998400, value: 0.364),
            GraphEntry(timestamp: 1654002000, value: 0.448),
            GraphEntry(timestamp: 1654005600, value: 0.128),
            GraphEntry(timestamp: 1654009200, value: 0.254),
            GraphEntry(timestamp: 1654012800, value: 0.382),
            GraphEntry(timestamp: 1654016400, value: 0.176),
            GraphEntry(timestamp: 1654020000, value: 0.241),
            GraphEntry(timestamp: 1654023600, value: 0.198),
            GraphEntry(timestamp: 1654027200, value: 0.457),
            GraphEntry(timestamp: 1654030800, value: 0.263),
            GraphEntry(timestamp: 1654034400, value: 0.423),
            GraphEntry(timestamp: 1654038000, value: 0.399),
            GraphEntry(timestamp: 1654041600, value: 0.194),
            GraphEntry(timestamp: 1654045200, value: 0.473),
            GraphEntry(timestamp: 1654048800, value: 0.386),
            GraphEntry(timestamp: 1654052400, value: 0.415),
            GraphEntry(timestamp: 1654056000, value: 0.263),
            GraphEntry(timestamp: 1654059600, value: 0.314),
            GraphEntry(timestamp: 1654063200, value: 0.225),
            GraphEntry(timestamp: 1654066800, value: 0.337),
            GraphEntry(timestamp: 1654070400, value: 0.145),
            GraphEntry(timestamp: 1654074000, value: 0.492),
            GraphEntry(timestamp: 1654077600, value: 0.281),
            GraphEntry(timestamp: 1654081200, value: 0.367),
            GraphEntry(timestamp: 1654084800, value: 0.399),
            GraphEntry(timestamp: 1654088400, value: 0.222),
            GraphEntry(timestamp: 1654092000, value: 0.298),
            GraphEntry(timestamp: 1654095600, value: 0.481),
            GraphEntry(timestamp: 1654099200, value: 0.413),
            GraphEntry(timestamp: 1654102800, value: 0.247),
            GraphEntry(timestamp: 1654106400, value: 0.197),
            GraphEntry(timestamp: 1654110000, value: 0.341),
            GraphEntry(timestamp: 1654113600, value: 0.389),
            GraphEntry(timestamp: 1654117200, value: 0.219),
            GraphEntry(timestamp: 1654120800, value: 0.455),
            GraphEntry(timestamp: 1654124400, value: 0.183),
            GraphEntry(timestamp: 1654128000, value: 0.431),
            GraphEntry(timestamp: 1654131600, value: 0.275),
            GraphEntry(timestamp: 1654135200, value: 0.354),
            GraphEntry(timestamp: 1654138800, value: 0.326),
            GraphEntry(timestamp: 1654142400, value: 0.482),
            GraphEntry(timestamp: 1654146000, value: 0.277),
            GraphEntry(timestamp: 1654149600, value: 0.223),
            GraphEntry(timestamp: 1654153200, value: 0.144),
            GraphEntry(timestamp: 1654156800, value: 0.317),
            GraphEntry(timestamp: 1654160400, value: 0.491),
            GraphEntry(timestamp: 1654164000, value: 0.385),
            GraphEntry(timestamp: 1654167600, value: 0.465),
            GraphEntry(timestamp: 1654171200, value: 0.356),
            GraphEntry(timestamp: 1654174800, value: 0.298),
            GraphEntry(timestamp: 1654178400, value: 0.417),
            GraphEntry(timestamp: 1654182000, value: 0.439),
            GraphEntry(timestamp: 1654185600, value: 0.389),
            GraphEntry(timestamp: 1654189200, value: 0.374),
            GraphEntry(timestamp: 1654192800, value: 0.219),
            GraphEntry(timestamp: 1654196400, value: 0.313),
            GraphEntry(timestamp: 1654200000, value: 0.197),
            GraphEntry(timestamp: 1654203600, value: 0.364),
            GraphEntry(timestamp: 1654207200, value: 0.418),
            GraphEntry(timestamp: 1654210800, value: 0.175),
            GraphEntry(timestamp: 1654214400, value: 0.249),
            GraphEntry(timestamp: 1654218000, value: 0.474),
            GraphEntry(timestamp: 1654221600, value: 0.284),
            GraphEntry(timestamp: 1654225200, value: 0.472),
            GraphEntry(timestamp: 1654228800, value: 0.392),
            GraphEntry(timestamp: 1654232400, value: 0.268),
            GraphEntry(timestamp: 1654236000, value: 0.189),
            GraphEntry(timestamp: 1654239600, value: 0.154),
            GraphEntry(timestamp: 1654243200, value: 0.293),
            GraphEntry(timestamp: 1654246800, value: 0.345),
            GraphEntry(timestamp: 1654250400, value: 0.471),
            GraphEntry(timestamp: 1654254000, value: 0.316),
            GraphEntry(timestamp: 1654257600, value: 0.396),
            GraphEntry(timestamp: 1654261200, value: 0.291),
            GraphEntry(timestamp: 1654264800, value: 0.312),
            GraphEntry(timestamp: 1654268400, value: 0.257),
            GraphEntry(timestamp: 1654272000, value: 0.278),
            GraphEntry(timestamp: 1654275600, value: 0.489),
            GraphEntry(timestamp: 1654279200, value: 0.168),
            GraphEntry(timestamp: 1654282800, value: 0.476),
            GraphEntry(timestamp: 1654286400, value: 0.271),
            GraphEntry(timestamp: 1654290000, value: 0.413),
            GraphEntry(timestamp: 1654293600, value: 0.185),
            GraphEntry(timestamp: 1654297200, value: 0.353),
            GraphEntry(timestamp: 1654300800, value: 0.312),
            GraphEntry(timestamp: 1654304400, value: 0.246),
            GraphEntry(timestamp: 1654308000, value: 0.459),
            GraphEntry(timestamp: 1654311600, value: 0.349),
            GraphEntry(timestamp: 1654315200, value: 0.389),
            GraphEntry(timestamp: 1654318800, value: 0.284),
            GraphEntry(timestamp: 1654322400, value: 0.264),
            GraphEntry(timestamp: 1654326000, value: 0.326),
            GraphEntry(timestamp: 1654329600, value: 0.493),
            GraphEntry(timestamp: 1654333200, value: 0.214),
            GraphEntry(timestamp: 1654336800, value: 0.461),
            GraphEntry(timestamp: 1654340400, value: 0.392),
            GraphEntry(timestamp: 1654344000, value: 0.247),
            GraphEntry(timestamp: 1654347600, value: 0.498),
            GraphEntry(timestamp: 1654351200, value: 0.341),
            GraphEntry(timestamp: 1654354800, value: 0.457),
            GraphEntry(timestamp: 1654358400, value: 0.379),
            GraphEntry(timestamp: 1654362000, value: 0.423),
            GraphEntry(timestamp: 1654365600, value: 0.267),
            GraphEntry(timestamp: 1654369200, value: 0.364),
            GraphEntry(timestamp: 1654372800, value: 0.276),
            GraphEntry(timestamp: 1654376400, value: 0.315),
            GraphEntry(timestamp: 1654380000, value: 0.163),
            GraphEntry(timestamp: 1654383600, value: 0.457),
            GraphEntry(timestamp: 1654387200, value: 0.291),
            GraphEntry(timestamp: 1654390800, value: 0.487),
            GraphEntry(timestamp: 1654394400, value: 0.314),
            GraphEntry(timestamp: 1654398000, value: 0.219),
            GraphEntry(timestamp: 1654401600, value: 0.453),
            GraphEntry(timestamp: 1654405200, value: 0.234),
            GraphEntry(timestamp: 1654410000, value: 0.472)
        ]
    }
}
