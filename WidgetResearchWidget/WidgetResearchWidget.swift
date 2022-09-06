//
//  WidgetResearchWidget.swift
//  WidgetResearchWidget
//
//  Created by Ernest Chechelski on 06/09/2022.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), earnedMoney: 0, expectedDate: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), earnedMoney: 0, expectedDate: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        let entry = SimpleEntry(
            date: Date(),
            earnedMoney: UserDefaults.appGroup.integer(forKey: "earnedMoney"),
            expectedDate: Date(timeIntervalSince1970: UserDefaults.appGroup.double(forKey: "expectedDate"))
        )
        entries.append(entry)
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let earnedMoney: Int
    let expectedDate: Date
}

struct WidgetResearchWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text(entry.date, style: .time)
            Text("Earned money:")
            Text(entry.earnedMoney, format: .number)
            Text("Expected date: \(entry.expectedDate.asExpectedDescription)")
        }
    }
}

@main
struct WidgetResearchWidgets: WidgetBundle {
   var body: some Widget {
       WidgetResearchWidget()
       NextMoneyActivityWidget()
   }
}

struct WidgetResearchWidget: Widget {
    let kind: String = "WidgetResearchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetResearchWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct WidgetResearchWidget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetResearchWidgetEntryView(entry: SimpleEntry(date: Date(), earnedMoney: 0, expectedDate: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
