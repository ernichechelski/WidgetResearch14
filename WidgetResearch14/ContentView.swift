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
    
    enum Constants {
        static let buttonWidth: CGFloat = 150
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10) {
                Text(
                    """
                    ℹ️ You can earn money immediately, so the app will ask server for random amount of money.
                    You can spend money immediately, which will reduce amount of earned money, also
                    You can schedule delivery of next money. Then please wait for notification.
                    """
                )
                    .font(.system(.subheadline, design: .rounded))
                    .padding(5)
                    .border(.black)
                VStack(alignment: .leading) {
                    Text("You have earned")
                        .font(.system(.subheadline, design: .rounded))
                    Text(appLogic.earnedMoney, format: .pln())
                        .font(.system(.title, design: .rounded))
                }
                VStack(alignment: .leading) {
                    Text(appLogic.expectedTimeDescription)
                        .font(.title2)
                    if appLogic.nextDate.isFuture {
                        Text(appLogic.nextDate, style: .timer)
                            .font(.title2)
                    }
                }
                Spacer()
                VStack(alignment: .center) {
                    Button {
                        Task {
                            await appLogic.spendMoney()
                        }
                    } label: {
                        Text("Spend money right now!")
                            .frame(width: Constants.buttonWidth)
                    }
                    .tint(.red)
                    .buttonStyle(.bordered)
                    Button {
                        Task {
                            await appLogic.earnMoney()
                        }
                    } label: {
                        Text("Earn money right now!")
                            .frame(width: Constants.buttonWidth)
                    }
                    .tint(.green)
                    .buttonStyle(.bordered)
                    
                    if !appLogic.nextDate.isFuture {
                        Button {
                            Task {
                                await appLogic.scheduleNewMoney()
                            }
                        } label: {
                            Text("Schedule new money!")
                                .frame(width: Constants.buttonWidth)
                        }
                        .tint(.blue)
                        .buttonStyle(.bordered)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(10)
            .frame(
                  minWidth: 0,
                  maxWidth: .infinity,
                  minHeight: 0,
                  maxHeight: .infinity,
                  alignment: .topLeading
            )
            .font(.system(.body, design: .rounded))
            .navigationTitle("Work simulator")
            .alert("Money earned!", isPresented: $appLogic.showEarnMoneyAlert) {
                Button("Thanks", role: .cancel) { }
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
