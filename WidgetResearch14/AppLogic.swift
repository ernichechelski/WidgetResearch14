//
//  AppLogic.swift
//  WidgetResearch14
//
//  Created by Ernest Chechelski on 06/09/2022.
//

import Foundation
import WidgetKit
import NotificationCenter
import SwiftUI
import ActivityKit

@MainActor
final class AppLogic: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    @AppStorage("earnedMoney", store: .appGroup) var earnedMoney = 0
    @AppStorage("expectedDate", store: .appGroup) var expectedDateTimeInterval: Double = 0
    
    
    var expectedTimeDescription: String {
        
        let date = Date(timeIntervalSince1970: expectedDateTimeInterval)
        guard date.timeIntervalSinceNow >= 0.0 else {
            return "Please schedule next money!"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .long
        return formatter.string(from: Date(timeIntervalSince1970: expectedDateTimeInterval))
    }
    
    enum Constants {
        static let categoryIdentifier = "GENERAL"
        static let snoozeActionIdentifier = "SNOOZE_ACTION"
        static let receiveMoneyActionIdentifier = "RECEIVE_ACTION"
        static let widgetKind: String = "WidgetResearchWidget"
    }
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted else { return }
            self.setup()
            // Enable or disable features based on the authorization.
        }
    }
    
    private func setup() {
        let snoozeAction = UNNotificationAction(
            identifier: Constants.snoozeActionIdentifier,
            title: "Snooze 1 minute",
            options: UNNotificationActionOptions(rawValue: 0)
        )
        
        let receiveMoneyAction = UNNotificationAction(
            identifier: Constants.receiveMoneyActionIdentifier,
            title: "Receive Money!",
            options: UNNotificationActionOptions(rawValue: 0)
        )
        
        let generalCategory = UNNotificationCategory(
            identifier: Constants.categoryIdentifier,
            actions: [snoozeAction, receiveMoneyAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
    
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([generalCategory])
        notificationCenter.delegate = self
    }
    
    private var notificationContent: UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "More money!"
        content.body = "You have earned next money by your work!"
        content.categoryIdentifier = Constants.categoryIdentifier
        return content
    }
    
    private func scheduleNotification(atMinute minute: Int = 1) -> Date? {
        // Configure the recurring date.
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.hour = Calendar.current.component(.hour, from: Date())
        dateComponents.minute = Calendar.current.component(.minute, from: Date()) + minute
           
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(
                 dateMatching: dateComponents, repeats: true)
        let uuidString = UUID().uuidString
        
        
        let request = UNNotificationRequest(identifier: uuidString,
                    content: notificationContent, trigger: trigger)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests()
        
        notificationCenter.add(request) { (error) in
           if error != nil {
               print("Error \(error!)")
              // Handle any errors.
           }
            else {
                print("Notification scheduled!")
            }
        }
        return trigger.nextTriggerDate()
    }
    
    func scheduleNewMoney() {
        if let date = scheduleNotification() {
            startActivity(to: date)
        }
    }
    
    private func snoozeNotification(atMinute minutes: Int = 1) -> Date? {
        // Create the trigger as a repeating event.
        let interval:TimeInterval = Double(60 * minutes) // 1 minute = 60 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                    content: notificationContent, trigger: trigger)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.add(request) { (error) in
           if error != nil {
               print("Error \(error!)")
              // Handle any errors.
           }
            else {
                print("Notification scheduled!")
            }
        }
        
        return trigger.nextTriggerDate()
    }
    
    private func startActivity(to: Date) {
        if let currentActivity = Activity<MoneyAttributes>.activities.first, currentActivity.activityState == .active {
            Task {
                let updatedMoneyStatus = MoneyAttributes.ContentState(maxExpectedMoney: earnedMoney + 20, expectedDate: to)
                await currentActivity.update(using: updatedMoneyStatus)
                expectedDateTimeInterval = to.timeIntervalSince1970
                updateWidgets()
                print("Activity updated!")
            }
            return
        }
            
        let attributes =  MoneyAttributes(currentMoney: earnedMoney)

        // Estimated delivery time is one hour from now.
        let initialContentState = MoneyAttributes.ContentState(maxExpectedMoney: earnedMoney + 20, expectedDate: to)
                                                  
        do {
            let deliveryActivity = try Activity<MoneyAttributes>.request(
                attributes: attributes,
                contentState: initialContentState,
                pushType: nil)
            print("Waiting for next money! \(deliveryActivity.id)")
            expectedDateTimeInterval = to.timeIntervalSince1970
            updateWidgets()
        } catch (let error) {
            print("Error waiting for next money Live Activity \(error.localizedDescription)")
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        .banner
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        switch response.actionIdentifier {
        case Constants.snoozeActionIdentifier:
            if let date = snoozeNotification(atMinute: 1) {
                startActivity(to: date)
            }
        case Constants.receiveMoneyActionIdentifier:
            earnMoney()
        default: earnMoney()
        }
    }
    
    func stopActivities() async {
        for activity in Activity<MoneyAttributes>.activities {
            let updatedMoneyStatus = MoneyAttributes.ContentState(maxExpectedMoney: earnedMoney, expectedDate: Date())
            await activity.end(using: updatedMoneyStatus, dismissalPolicy: .immediate)
        }
    }
    
    func updateWidgets() {
        WidgetCenter.shared.reloadTimelines(ofKind: Constants.widgetKind)
    }
    
    func earnMoney() {
        Task {
            do {
                let randomNumber = try await URLSession.shared.randomNumberPublisher()
                self.earnedMoney += randomNumber
                updateWidgets()
                await stopActivities()
            }
            catch {
                print(error)
            }
        }
    }
    
    func spendMoney() {
        Task {
            do {
                self.earnedMoney -= 10
            }
            catch {
                print(error)
            }
        }
    }
}
