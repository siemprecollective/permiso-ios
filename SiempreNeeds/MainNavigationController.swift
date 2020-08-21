//
//  MainNavigationController.swift
//  SiempreNeeds
//


import UIKit
import UserNotifications

class MainNavigationController: UINavigationController, UserProfileDelegate, ExpressionManagerDelegate {
    var isPresentingProfile = false

    override func viewDidLoad() {
        super.viewDidLoad()
        UserProfile.shared.setDelegate(self)
        UserProfile.shared.configure()
        ExpressionManager.shared.setDelegate(self)
        ExpressionManager.shared.configure()
        self.requestNotificationPermission() { success in
            // TODO do something
        }
    }
    
    func userNeedsProfile() {
        isPresentingProfile = true
        performSegue(withIdentifier: "profileIncomplete", sender: nil)
    }
    
    func userDidLoad() {
        if (isPresentingProfile) {
            isPresentingProfile = false
            self.dismiss(animated: true) {}
        }
    }
    
    func expressionsDidLoad() {
        if (ExpressionManager.shared.notification != nil) {// todo what happens if profile unset and get notification?
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let rvc = storyboard.instantiateViewController(withIdentifier: "ResponseViewController") as! ResponseViewController
            rvc.expression = ExpressionManager.shared.notification
            ExpressionManager.shared.reset(notificationExpressionId: ())
            self.pushViewController(rvc, animated: false)
        }
    }
    
    func requestNotificationPermission(completion: @escaping (_ permissionGranted: Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            if (settings.authorizationStatus == .denied) {
                Log("User notification permission denied. Go to system settings to allow user notifications.")
                completion(false)
            } else if (settings.authorizationStatus == .authorized) {
                Log("User notification already authorized.")
                completion(true)
            } else if (settings.authorizationStatus == .notDetermined) {
                let options: UNAuthorizationOptions = [.alert, .sound]
                center.requestAuthorization(options: options, completionHandler: { (granted, error) in
                    if (error != nil) {
                        Log("Failed to request for user notification permission: \(error!.localizedDescription)")
                        completion(false)
                    }
                    
                    if (granted) {
                        Log("User notification permission granted.")
                        completion(true)
                    } else {
                        Log("User notification permission denied.")
                        completion(false)
                    }
                })
            }
        }
    }
}
