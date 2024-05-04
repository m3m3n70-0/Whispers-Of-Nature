import UIKit
import SwiftUI
import UserNotifications
import AVFoundation

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private var notificationID: String?
    static let shared = AppDelegate()
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        
        // Request notification permissions as soon as the app launches
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
                self.setupNotificationActionsAndCategory()
                // Optional: Test scheduling notification directly after launch
//                self.testScheduleNotification()
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }

        // Setup the audio session
        setupAudioSession()

        return true
    }
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            print("Audio session successfully activated.")
        } catch {
            print("Failed to activate audio session: \(error)")
        }
    }
    
    func setupNotificationActionsAndCategory() {
        let stopAction = UNNotificationAction(identifier: "STOP_AUDIO", title: "Stop", options: .foreground)
        let category = UNNotificationCategory(identifier: "ACTIONS", actions: [stopAction], intentIdentifiers: [], options: [.customDismissAction])

        UNUserNotificationCenter.current().setNotificationCategories([category])
        print("Notification actions and category set up.")
    }


    func applicationDidEnterBackground(_ application: UIApplication) {
        print("App entered background.")
        scheduleNotification()
    }

    func scheduleNotification() {
            let content = UNMutableNotificationContent()
            content.title = "Audio Still Playing"
            content.body = "Tap to stop playing."
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = "ACTIONS"

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            notificationID = request.identifier

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                } else {
                    print("Notification scheduled successfully")
                }
            }
        }

        func cancelNotification() {
            if let id = notificationID {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                print("Notification cancelled")
            }
        }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification will present in foreground.")
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Notification action received: \(response.actionIdentifier)")
        if response.actionIdentifier == "STOP_AUDIO" || response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            DispatchQueue.main.async {
                AudioViewModel.shared.stopAllAudio()
            }
        }
        completionHandler()
    }

    
    func testScheduleNotification() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {  // Schedules a test notification 5 seconds after app launch
            self.scheduleNotification()
            print("Test notification scheduled to fire in 1 seconds.")
        }
    }
    }



    



