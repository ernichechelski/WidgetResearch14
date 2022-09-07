//
//  NextMoneyActivityWidget.swift
//  WidgetResearch14
//
//  Created by Ernest Chechelski on 07/09/2022.
//

import SwiftUI
import WidgetKit
import ActivityKit

/// Widget used for live activity.
struct NextMoneyActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(attributesType: MoneyAttributes.self) { context in
            Group {
                if context.state.finished {
                    VStack(alignment: .leading) {
                        Text("You have:")
                        Text(context.attributes.currentMoney, format: .pln())
                        Text("Money was delivered! You can schedule next money.")
                    }
                    .padding(5)
                } else {
                    VStack(alignment: .leading) {
                        Text("You have:")
                        Text(context.attributes.currentMoney, format: .pln())
                        Text("You can have even:")
                        Text(context.state.maxExpectedMoney, format: .pln())
                        Text("just wait to:")
                        Text(context.state.expectedDate, style: .timer)
                    }
                    .padding(5)
                }
            }
            .activityBackgroundTint(Color.cyan)
        }
    }
}

struct MoneyAttributes: ActivityAttributes {
    public typealias MoneyStatus = ContentState

    public struct ContentState: Codable, Hashable {
        var maxExpectedMoney: Int
        var expectedDate: Date
        var finished: Bool
    }

    var currentMoney: Int
}
