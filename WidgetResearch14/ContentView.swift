//
//  ContentView.swift
//  Shared
//
//  Created by Ernest Chechelski on 06/09/2022.
//

import SwiftUI
import NotificationCenter

struct ContentView: View {
    
    @EnvironmentObject var appLogic: AppLogic
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                VStack {
                    Text("You have earned")
                    Text(appLogic.earnedMoney, format: .number)
                }
                VStack {
                    Text("Next money will be delivered at:")
                    Text(appLogic.expectedTimeDescription)
                }
                VStack {
                    Button {
                        appLogic.spendMoney()
                    } label: {
                        Text("Spend money right now!")
                    }
                    .buttonStyle(.bordered)
                    
                    Button {
                        appLogic.scheduleNewMoney()
                    } label: {
                        Text("Schedule new money!")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .font(.system(.body, design: .rounded))
            .padding()
            .navigationTitle("Work simulator")
        }
        
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
