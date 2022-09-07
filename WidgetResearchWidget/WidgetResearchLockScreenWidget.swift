//
//  WidgetResearchLockScreenWidget.swift
//  WidgetResearch14
//
//  Created by Ernest Chechelski on 07/09/2022.
//

import SwiftUI
import WidgetKit

struct WidgetResearchLockScreenWidget: Widget {
    private let kind: String = "WidgetResearchWidget"

    public var body: some WidgetConfiguration {
        StaticConfiguration.init(kind: kind, provider: Provider()) { entry in
            WidgetResearchLockScreenWidgetView(entry: entry)
        }
        .configurationDisplayName("Widget Research Widget")
        .description("Money earned percentage")
    #if os(watchOS)
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline, .accessoryCorner])
    #else
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline, .systemSmall, .systemMedium])
    #endif
    }
}

struct WidgetResearchLockScreenWidgetView: View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        switch family {
        case .accessoryInline:
            // Code to construct the view for the inline widget or watch complication.
            Text(verbatim: entry.earnedMoney.formatted(.pln()))
        case .accessoryRectangular:
            // Code to construct the view for the rectangular Lock Screen widget or watch complication.
            VStack(alignment: .leading) {
                Text(verbatim: entry.earnedMoney.formatted(.pln()))
                Text(entry.expectedDate, style: .timer)
            }
        case .accessoryCircular:
            // Code to construct the view for the circular Lock Screen widget or watch complication.
            Gauge(value: entry.progress) {
                Text("💸")
            }.gaugeStyle(.accessoryCircular)
        case .systemSmall:
            // Code to construct the view for small space.
            Text(verbatim: entry.earnedMoney.formatted(.pln()))
        default:
            // Code to construct the view for any kind of widget,
            // automaticaly selects the version which fits the desired space.
            ViewThatFits {
                Text(verbatim: entry.earnedMoney.formatted(.pln()))
                VStack(alignment: .leading) {
                    Text(verbatim: entry.earnedMoney.formatted(.pln()))
                    Text(entry.expectedDate, style: .timer)
                }
                VStack(alignment: .leading) {
                    Text(verbatim: entry.earnedMoney.formatted(.pln()))
                    Text(entry.expectedDate, style: .timer)
                    Gauge(value: entry.progress) {
                        Text("💸")
                    }.gaugeStyle(.accessoryCircular)
                }
            }
        }
    }
}
