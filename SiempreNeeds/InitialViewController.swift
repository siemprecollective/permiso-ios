//
//  InitialViewController.swift
//  SiempreNeeds
//


import UIKit

class InitialViewController: UIViewController, UserAuthDelegate {
    override func viewDidAppear(_ animated: Bool) {
        UserAuth.shared.delegate = self
        UserAuth.shared.configure()
    }
    
    func didFailToLogIn() {
        performSegue(withIdentifier: "notAuthenticated", sender: nil)
    }
    
    func didLogIn() {
        performSegue(withIdentifier: "authenticated", sender: nil)
    }
    
    func didStartLogIn() {
        // unused
    }
}
