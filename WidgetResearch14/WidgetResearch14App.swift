//
//  WidgetResearch14App.swift
//  WidgetResearch14
//
//  Created by Ernest Chechelski on 06/09/2022.
//

import SwiftUI

@main
struct WidgetResearch14App: App {
    
    @StateObject var appLogic = AppLogic()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appLogic)
        }
    }
}
