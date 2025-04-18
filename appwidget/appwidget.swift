//
//  appwidget.swift
//  appwidget
//
//  Created by Marcelino on 24/3/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ExecutionsEntry {
        ExecutionsEntry(date: Date(), executions: Execution.dummyExecutions)
    }

    func getSnapshot(in context: Context, completion: @escaping (ExecutionsEntry) -> ()) {
        let entry = ExecutionsEntry(date: Date(), executions: Execution.dummyExecutions)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [ExecutionsEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = ExecutionsEntry(date: entryDate, executions: Execution.dummyExecutions)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct ExecutionsEntry: TimelineEntry {
    let date: Date
    let executions: [Execution]
}

struct WidgetExecutionsSmallView : View {
    let execution: Execution
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.6, green: 0.65, blue: 0.7))
                .shadow(radius: 5)
            VStack(alignment: .leading) {
                HStack {
                    Text("#\(execution.id)")
                        .fontWeight(.bold)
                    Spacer()
                }
                VStack(alignment: .leading) {
                    Text("Executed at")
                        .font(.caption.italic())
                    Text(execution.startedAt.date?.dateString ?? "-")
                        .font(.caption2.bold())
                }
                VStack(alignment: .leading) {
                    if execution.finished {
                        Text("Succeeded in")
                            .foregroundStyle(Color("Green"))
                            .font(.caption.italic())
                            .fontWeight(.bold)
                    } else {
                        Text("Error in")
                            .foregroundStyle(Color("Red"))
                            .font(.caption.italic())
                            .fontWeight(.bold)
                    }
                    if let executionTimeInSeconds = execution.executionTimeInSeconds {
                        Text("\(String(format: "%.3f", executionTimeInSeconds))s")
                            .font(.caption.bold())
                    }
                }
            }
            .padding(.horizontal)
        }
        .foregroundStyle(.white)
    }
}

struct appwidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry
    var execution: Execution {
        entry.executions.last ?? Execution.dummyExecutions[0]
    }
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            WidgetExecutionsSmallView(execution: execution)
        case .systemMedium:
            Text("Hola")
        default:
            Text("Adios")
        }
    }
}

struct appwidget: Widget {
    let kind: String = "appwidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            appwidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color.clear
                }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge
        ])
    }
}

#Preview(as: .systemSmall) {
    appwidget()
} timeline: {
    ExecutionsEntry(date: .now, executions: Execution.dummyExecutions)
}

#Preview(as: .systemMedium) {
    appwidget()
} timeline: {
    ExecutionsEntry(date: .now, executions: Execution.dummyExecutions)
}

#Preview(as: .systemLarge) {
    appwidget()
} timeline: {
    ExecutionsEntry(date: .now, executions: Execution.dummyExecutions)
}
