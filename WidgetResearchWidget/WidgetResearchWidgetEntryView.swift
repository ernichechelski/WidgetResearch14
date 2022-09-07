//
//  WidgetResearchWidgetEntryView.swift
//  WidgetResearch14
//
//  Created by Ernest Chechelski on 07/09/2022.
//

import WidgetKit
import SwiftUI

struct WidgetResearchWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Last update")
            Text(entry.date, style: .time)
            Text("Earned money:")
            Text(entry.earnedMoney, format: .pln())
            Text("Expected date: \(entry.expectedDate.asExpectedDescription)")
        }
        .padding()
    }
}
