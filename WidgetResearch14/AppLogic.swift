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
final class AppLogic: NSObject, ObservableObject {
    
    @Published var showEarnMoneyAlert = false
    @AppStorage("earnedMoney", store: .appGroup) var earnedMoney = 0
    @AppStorage("expectedDate", store: .appGroup) var expectedDateTimeInterval: Double = 0
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    var timer: Timer?
    
    override init() {
        super.init()
        askPermissions()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            withAnimation {
                self.objectWillChange.send()
            }
        })
    }
    
    /// Schedules new money.
    func scheduleNewMoney() async {
        
        do {
            if let date = try await scheduleNotification() {
                await startActivity(to: date)
            }
        } catch {
            print(error)
        }
    }

    /// Earns money immediately.
    func earnMoney() async {
        do {
            let randomNumber = try await URLSession.shared.randomNumberRequest()
            earnedMoney += randomNumber
            expectedDateTimeInterval = Date().timeIntervalSince1970
            await updateWidgets()
            await stopActivities()
            await showAlert()
        }
        catch {
            print(error)
        }
    }
    
    func showAlert() async {
        showEarnMoneyAlert = true
    }
    
    /// Reduces amount of money.
    func spendMoney() async {
        earnedMoney -= 10
    }
}

// Mark: - UNUserNotificationCenterDelegate

extension AppLogic: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        .banner
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        do {
            switch response.actionIdentifier {
            case Constants.snoozeActionIdentifier:
                if let date = try await snoozeNotification(atMinute: 1) {
                    await startActivity(to: date)
                }
            case Constants.receiveMoneyActionIdentifier:
                await earnMoney()
            default: await earnMoney()
            }
        }
        catch {
            print(error)
        }
    }
}

extension AppLogic {
    
    var expectedTimeDescription: String {
        let date = nextDate
        guard date.isFuture else {
            return "Please schedule next money!"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .long
        return "Next money will be delivered at \(formatter.string(from: Date(timeIntervalSince1970: expectedDateTimeInterval)))"
    }
    
    var nextDate: Date {
        Date(timeIntervalSince1970: expectedDateTimeInterval)
    }
}

private extension AppLogic {
        
    enum Constants {
        static let categoryIdentifier = "GENERAL"
        static let snoozeActionIdentifier = "SNOOZE_ACTION"
        static let receiveMoneyActionIdentifier = "RECEIVE_ACTION"
        static let widgetKind: String = "WidgetResearchWidget"
    }

    private func askPermissions() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted else { return }
            self.setup()
        }
    }
    
    private var notificationCategories: Set<UNNotificationCategory> {
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
        return [generalCategory]
    }
    
    var notificationContent: UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "More money!"
        content.body = "You have earned next money by your work!"
        content.categoryIdentifier = Constants.categoryIdentifier
        return content
    }
    
    func setup() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories(notificationCategories)
        notificationCenter.delegate = self
    }
    
    func scheduleNotification(atMinute minute: Int = 1) async throws -> Date? {
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
        Task {
            try await notificationCenter.add(request)
        }
        return trigger.nextTriggerDate()
    }
    
    func snoozeNotification(atMinute minutes: Int = 1) async throws -> Date? {
        // Create the trigger as a repeating event.
        let interval:TimeInterval = Double(60 * minutes) // 1 minute = 60 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                    content: notificationContent, trigger: trigger)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests()
        try await notificationCenter.add(request)
        return trigger.nextTriggerDate()
    }
    
    func startActivity(to: Date) async {
        if let currentActivity = Activity<MoneyAttributes>.activities.first, currentActivity.activityState == .active {
            let updatedMoneyStatus = MoneyAttributes.ContentState(maxExpectedMoney: earnedMoney + 20, expectedDate: to, finished: false)
            await currentActivity.update(using: updatedMoneyStatus)
            expectedDateTimeInterval = to.timeIntervalSince1970
            await updateWidgets()
            print("Activity updated!")
        }
            
        let attributes =  MoneyAttributes(currentMoney: earnedMoney)
                                  
        do {
            let initialContentState = MoneyAttributes.ContentState(maxExpectedMoney: earnedMoney + 20, expectedDate: to, finished: false)
            
            let deliveryActivity = try Activity<MoneyAttributes>.request(
                attributes: attributes,
                contentState: initialContentState,
                pushType: nil
            )
            
            print("Waiting for next money! \(deliveryActivity.id)")
            withAnimation {
                expectedDateTimeInterval = to.timeIntervalSince1970
            }
           
            await updateWidgets()
            await scheduleEndActivity(deliveryActivity, to: to)
        } catch (let error) {
            print("Error waiting for next money Live Activity \(error.localizedDescription)")
        }
    }
    
    func scheduleEndActivity(_ activity: Activity<MoneyAttributes>, to: Date) async {
        /// Impossible to do so locally. You have to request external service to send notification at desired time.
    }
    
    func stopActivities() async {
        for activity in Activity<MoneyAttributes>.activities {
            let updatedMoneyStatus = MoneyAttributes.ContentState(maxExpectedMoney: earnedMoney, expectedDate: Date(), finished: true)
            await activity.end(using: updatedMoneyStatus, dismissalPolicy: .default)
        }
    }
    
    func updateWidgets() async {
        UserDefaults.appGroup.synchronize()
        WidgetCenter.shared.reloadTimelines(ofKind: Constants.widgetKind)
    }
}
