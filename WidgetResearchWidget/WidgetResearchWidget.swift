//
//  WidgetResearchWidget.swift
//  WidgetResearchWidget
//
//  Created by Ernest Chechelski on 06/09/2022.
//

import WidgetKit
import SwiftUI

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
        WidgetResearchLockScreenWidgetView(entry: SimpleEntry(date: Date(), earnedMoney: 0, expectedDate: Date()))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    }
}
