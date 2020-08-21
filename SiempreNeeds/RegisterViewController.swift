//
//  RegisterViewController.swift
//  


import UIKit

class RegisterViewController: UIViewController, UserAuthDelegate {
    @IBOutlet weak var numberInput: UITextField!
    
    override func viewDidAppear(_ animated: Bool) {
        UserAuth.shared.delegate = self
    }

    @IBAction func tappedOutside(_ sender: Any) {
        numberInput.resignFirstResponder()
    }
    
    @IBAction func numberEntered(_ sender: Any) {
        UserAuth.shared.startLogin(phoneNumber: numberInput.text!)
    }

    func didStartLogIn() {
        performSegue(withIdentifier: "entered", sender: nil)
    }
  
    func didFailToLogIn() {
    }
    
    func didLogIn() {
        // unused
    }
}
