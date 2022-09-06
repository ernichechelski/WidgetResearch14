//
//  Extensions.swift
//  WidgetResearch14
//
//  Created by Ernest Chechelski on 06/09/2022.
//

import ActivityKit
import Foundation
import WidgetKit

extension UserDefaults {
    static var appGroup: UserDefaults {
        UserDefaults(suiteName: "group.ernichechelski.CodeWidget")!
    }
}

import Combine

extension URLSession {
    func randomNumberPublisher() async throws -> Int {
        let (data, _) = try await URLSession.shared.data(from: URL(string: "http://localhost:8080/")!)
        return Int(data.uint8)
    }
}

extension Data {
    var uint8: UInt8 {
        var number: UInt8 = 0
        self.copyBytes(to: &number, count: MemoryLayout<UInt8>.size)
        return number
    }
}

import ActivityKit
import SwiftUI
import WidgetKit

struct MoneyAttributes: ActivityAttributes {
    public typealias MoneyStatus = ContentState

    public struct ContentState: Codable, Hashable {
        var maxExpectedMoney: Int
        var expectedDate: Date
    }

    var currentMoney: Int
}

struct NextMoneyActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(attributesType: MoneyAttributes.self) { context in
            VStack(alignment: .leading) {
                Text("You have \(context.attributes.currentMoney)")
                HStack {
                    Text("You can have even \(context.state.maxExpectedMoney), just wait to:")
                    Text(context.state.expectedDate, style: .timer)
                }
            }
            .padding(5)
            .activityBackgroundTint(Color.cyan)
        }
    }
}

extension Date {
    var asExpectedDescription: String {
        guard self.timeIntervalSinceNow >= 0.0 else {
            return "Please schedule next money!"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .long
        return formatter.string(from: self)
    }
}
