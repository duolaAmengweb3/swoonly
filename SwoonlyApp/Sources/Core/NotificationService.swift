import Foundation
import UserNotifications

enum NotificationService {
    private static let id = "swoonly.daily.reminder"
    static func enableDailyReminder() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            let c = UNMutableNotificationContent()
            c.title = "Your next chapter is waiting"
            c.body = "A few minutes of romance before bed?"
            c.sound = .default
            var dc = DateComponents(); dc.hour = 20
            let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
            let req = UNNotificationRequest(identifier: id, content: c, trigger: trigger)
            UNUserNotificationCenter.current().add(req)
        }
    }
    static func disable() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}
