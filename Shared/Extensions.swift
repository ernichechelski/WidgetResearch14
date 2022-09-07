//
//  Extensions.swift
//  WidgetResearch14
//
//  Created by Ernest Chechelski on 06/09/2022.
//

import Foundation
import WidgetKit
import SwiftUI

extension UserDefaults {
    /// Returns shared via AppGroup UserDefaults.
    static var appGroup: UserDefaults {
        UserDefaults(suiteName: "group.ernichechelski.CodeWidget")!
    }
}

extension URLSession {
    /// Returns random number fetched from the server.
    func randomNumberRequest() async throws -> Int {
        let (data, _) = try await URLSession.shared.data(from: URL(string: "http://localhost:8080/")!)
        return Int(data.uint8)
    }
}

extension Data {
    /// Parses data to Int value.
    var uint8: UInt8 {
        var number: UInt8 = 0
        self.copyBytes(to: &number, count: MemoryLayout<UInt8>.size)
        return number
    }
}

extension FormatStyle {
    /// Format style for Polish Złoty currency.
    static func pln<V>() -> Self where Self == IntegerFormatStyle<V>.Currency, V : BinaryInteger {
        .currency(code: "PLN")
    }
}

extension Date {
    /// Expected date description. This is just UI helper.
    var asExpectedDescription: String {
        guard isFuture else {
            return "Please schedule next money!"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .long
        return formatter.string(from: self)
    }
    
    /// Returns true if date is in future.
    var isFuture: Bool {
        timeIntervalSinceNow >= 0.0
    }
}
